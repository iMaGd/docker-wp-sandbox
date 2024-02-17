#!/bin/bash

set -e

# Default values
WORDPRESS_SITE_PORT=8081
#LOCAL_VOLUME="./my-plugin/:/var/www/html/wp-content/plugins/my-plugin"
LOCAL_VOLUME=""
PHP_VERSION=""
WORDPRESS_IMAGE_TAG=""
REBUILD=false
CLEAN_INSTALL=false
AUTO_INSTALL=false
AUTO_OPEN_IN_BROWSER=false
INSTALL_WP_CLI=false
WP_PLUGINS="+depicter,+query-monitor,-hello,-akismet"
WP_USER="admin"
WP_PASS="admin"
WP_EMAIL="admin@example.com"


# Usage message
function usage() {
    echo "Usage: $0 -p <port> -v <php-version> -b"
    echo "  -p, --port           Set the local port for WP site."
    echo "  -v, --volume         Set a local volume."
    echo "  -w,--wp-image        Set the WordPress Docker Image Tag."
    echo "  --php                Set the PHP version."
    echo "  -b, --rebuild        Trigger a rebuild."
    echo "  -c, --clean          Mark for fresh install."
    echo "  -o, --auto-open      Open the site in browser when site is ready."
    echo "  --auto-install       Install WP core and plugins."
    echo "  --wp-cli             Install WP-CLI."
    echo "  --wp-plugins         Set the list of WP plugin slugs, separated by commas."
    echo "  --wp-user            Set the WordPress admin username."
    echo "  --wp-pass            Set the WordPress admin password."
    echo "  --wp-email           Set the WordPress admin email."
    exit 1
}

# Check if no arguments were passed
if [ "$#" -eq 0 ]; then
    usage
fi

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--port) WORDPRESS_SITE_PORT="$2"; shift ;;
        --php) PHP_VERSION="$2"; shift ;;
        -v|--volume) LOCAL_VOLUME="$2"; shift ;;
        -w|--wp-image) WORDPRESS_IMAGE_TAG="$2"; shift ;;
        -b|--rebuild) REBUILD=true ;;
        -c|--clean) CLEAN_INSTALL=true ;;
        -o|--auto-open) AUTO_OPEN_IN_BROWSER=true ;;
        --auto-install) AUTO_INSTALL=true ;;
        --wp-cli) INSTALL_WP_CLI=true ;;
        --wp-plugins) WP_PLUGINS="$2"; shift ;;
        --wp-user) WP_USER="$2"; shift ;;
        --wp-pass) WP_PASS="$2"; shift ;;
        --wp-email) WP_EMAIL="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done



if [ -z "$WORDPRESS_IMAGE_TAG" ] && [ -z "$PHP_VERSION" ]; then
    echo "PHP and WordPress version not found, set to latest."
    WORDPRESS_IMAGE_TAG="apache"

elif [ -z "$PHP_VERSION" ]; then
    if [[ $WORDPRESS_IMAGE_TAG =~ php([0-9]+\.[0-9]+)(.+)? ]]; then
        PHP_VERSION="${BASH_REMATCH[1]}"
    fi
elif [ -z "$WORDPRESS_IMAGE_TAG" ]; then
    WORDPRESS_IMAGE_TAG="php${PHP_VERSION}-apache"
fi


# Get the name of the current directory
REPO_FOLDER_NAME=$(basename "$(pwd)")

export COMPOSE_PROJECT_NAME="${REPO_FOLDER_NAME}_${WORDPRESS_SITE_PORT}";
export WORDPRESS_SITE_PORT;

export WORDPRESS_DATA_DIR="./.stage/volumes/${WORDPRESS_SITE_PORT}/wp-content"
export PLUGINS_DATA_DIR="./.stage/volumes/${WORDPRESS_SITE_PORT}/plugins"
export DB_DATA_DIR="./.stage/volumes/${WORDPRESS_SITE_PORT}/db"
export WORDPRESS_IMAGE="wordpress:${WORDPRESS_IMAGE_TAG}"

export PMA_PORT="3${WORDPRESS_SITE_PORT}"
export DB_PORT="4${WORDPRESS_SITE_PORT}"
export LOCAL_VOLUME;

echo "Preparing to containerized WP installation on port $WORDPRESS_SITE_PORT with $WORDPRESS_IMAGE";

echo "local volume is $LOCAL_VOLUME"

# If REBUILD or FRESH_INSTALL was enabled
if [[ "$REBUILD" == true ]] || [[ "$CLEAN_INSTALL" == true ]]; then
    printf "\nStopping containers .. \n"
    # call the override docker compose file if $LOCAL_VOLUME is set
    if [ -z "$LOCAL_VOLUME" ]; then
        docker compose --env-file .docker/.env -f .docker/docker-compose.yml down
    else
        docker compose --env-file .docker/.env -f .docker/docker-compose.yml -f .docker/docker-compose-volume.yml down
    fi
fi

# If FRESH_INSTALL was enabled
if [[ "$CLEAN_INSTALL" == true ]]; then
    printf "\nCleaning volumes .. \n"
    rm -rf "./.docker/.stage/volumes/$WORDPRESS_SITE_PORT"
fi


# call the override docker compose file if $LOCAL_VOLUME is set
if [ -z "$LOCAL_VOLUME" ]; then
    docker compose --env-file .docker/.env -f .docker/docker-compose.yml up -d --remove-orphans
else
    docker compose --env-file .docker/.env -f .docker/docker-compose.yml -f .docker/docker-compose-volume.yml up -d --remove-orphans
fi

printf "\nWaiting for database container to get ready..."
    while ! docker compose exec db mysqladmin --user=root --password=root --host "127.0.0.1" ping --silent &> /dev/null ; do
    sleep 1
done


# If installing wp cli or auto install is enabled
if [[ "$INSTALL_WP_CLI" == true ]] || [[ "$AUTO_INSTALL" == true ]]; then
    docker compose exec wordpress bash -c "\
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod +x wp-cli.phar && \
  mv wp-cli.phar /usr/local/bin/wp"
fi

# If auto install is enabled
if [[ "$AUTO_INSTALL" == true ]]; then
    # Install WordPress using WP-CLI
    printf "\nInstalling WordPress .."
    docker compose exec wordpress wp core install --path="/var/www/html" --url="http://127.0.01:$WORDPRESS_SITE_PORT" --title="WP PHP $PHP_VERSION" --admin_user="$WP_USER" --admin_password="$WP_PASS" --admin_email="$WP_EMAIL" --allow-root
fi


process_wp_plugins() {
    local WP_PLUGINS=$1
    local PLUGIN_ARRAY
    local REMOVALS=()
    local INSTALLS=()
    local VERSIONS=()

    # Remove extra spaces and split into an array
    PLUGIN_ARRAY=($(echo $WP_PLUGINS | tr ',' '\n' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'))

    # Process each plugin and add it to the correct list
    for PLUGIN in "${PLUGIN_ARRAY[@]}"; do
        if [[ $PLUGIN == -* ]]; then
            # Remove the '-' prefix and add to REMOVALS
            REMOVALS+=("${PLUGIN:1}")
        else
            VERSION=""
            # Extract version if exists
            if [[ $PLUGIN == *@* ]]; then
                VERSION="${PLUGIN##*@}"
                PLUGIN="${PLUGIN%@*}"
            fi

            # Remove the '+' prefix if it exists
            if [[ $PLUGIN == +* ]]; then
                PLUGIN="${PLUGIN:1}"
            fi

            # Add PLUGIN to INSTALLS and VERSION to VERSIONS
            INSTALLS+=("$PLUGIN")
            VERSIONS+=("$VERSION")
        fi
    done

    # Print out the REMOVALS
    echo "Plugins to remove:"
    for PLUGIN in "${REMOVALS[@]}"; do
        docker compose exec wordpress wp plugin delete "$PLUGIN" --path="/var/www/html" --url="http://127.0.01:$WORDPRESS_SITE_PORT" --allow-root
    done

    # Print out the INSTALLS and their versions
    echo "Plugins with optional versions to install:"
    local INDEX=0
    for PLUGIN in "${INSTALLS[@]}"; do

        if [ -n "${VERSIONS[$INDEX]}" ]; then
            echo "Installing ${PLUGIN} (version: ${VERSIONS[$INDEX]})"
            docker compose exec wordpress wp plugin install "$PLUGIN" --path="/var/www/html" --url="http://127.0.01:$WORDPRESS_SITE_PORT" --version="${VERSIONS[$INDEX]}" --allow-root
        else
            docker compose exec wordpress wp plugin install "$PLUGIN" --path="/var/www/html" --url="http://127.0.01:$WORDPRESS_SITE_PORT" --allow-root
        fi
        docker compose exec wordpress wp plugin activate "$PLUGIN" --path="/var/www/html" --url="http://127.0.01:$WORDPRESS_SITE_PORT" --allow-root
        ((INDEX++))
    done
}


URL="http://127.0.0.1:${WORDPRESS_SITE_PORT}/wp-admin/"

# Auto install resources if enabled
if [ -n "$WP_PLUGINS" ] && [[ "$AUTO_INSTALL" == true ]]; then
    # Install or remove plugins
    process_wp_plugins "$WP_PLUGINS"
fi

printf "\nSetup completed."
printf "\nWordPress site: $URL"
echo "PhpMyAdmin: http://127.0.0.1:${PMA_PORT}"


if [[ "$AUTO_OPEN_IN_BROWSER" == true ]]; then

    # Open the link in browser
    case "$(uname)" in
        "Linux"*)
            xdg-open "$URL"
            ;;
        "Darwin"*)
            open "$URL"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            # For Git Bash, Cygwin, MSYS2 on Windows
            cmd.exe /c start "$URL"
            ;;
        *)
            echo "Platform not supported"
            exit 1
            ;;
    esac
fi
