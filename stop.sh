#!/bin/bash


# Default values
WORDPRESS_SITE_PORT=""
CLEAN_INSTALL=false
CLEAN_ALL=false

# Usage message
function usage() {
    echo "Usage: $0 -p <port>"
    echo "  -p, --port       Set the local port for WP site."
    echo "  -c, --clean      Mark for fresh install."
    exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--port) WORDPRESS_SITE_PORT="$2"; shift ;;
        --php) PHP_VERSION="$2"; shift ;;
        -c|--clean) CLEAN_INSTALL=true ;;
        --all) CLEAN_ALL=true ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done


if [ -z "$WORDPRESS_SITE_PORT" ]; then
    echo "You need to specify website port number to be stopped."
    usage;
fi


REPO_FOLDER_NAME=$(basename "$(pwd)")
export COMPOSE_PROJECT_NAME="${REPO_FOLDER_NAME}_${WORDPRESS_SITE_PORT}";

export WORDPRESS_DATA_DIR="./.stage/volumes/$WORDPRESS_SITE_PORT/wp/wp-content"
export DB_DATA_DIR="./.stage/volumes/$WORDPRESS_SITE_PORT/db"

echo "Stopping site on port $WORDPRESS_SITE_PORT";

docker compose --env-file .docker/.env -f .docker/docker-compose.yml down


# If CLEAN_INSTALL was enabled
if [[ "$CLEAN_INSTALL" == true ]]; then
    rm -rf "./.docker/.stage/volumes/$WORDPRESS_SITE_PORT"
    printf "\nALL volumes for this site are removed. \n"
fi
