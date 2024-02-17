## Local WordPress Docker Environment Generator

This repository helps you to easily set up a local WordPress environment using Docker including easy configuration of WordPress, PHPMyAdmin, and the option to install/uninstall plugins automatically. Also makes you able to generate a complete WordPress setup with any WordPress or PHP version of your choice. This guide will walk you through the process of cloning this repository, setting it up, and customizing it to fit your needs.

## Prerequisites

Before beginning, make sure you have Docker installed on your local machine. You can download Docker from the [official website](https://www.docker.com/products/docker-desktop).

## Getting Started

1. **Clone the Repository**

   First, clone this repository to your local machine:

   ```bash
   git clone https://github.com/iMaGd/docker-wp-sandbox.git
   cd docker-wp-sandbox
   ```
   Or download the repo from [releases page](https://github.com/iMaGd/docker-wp-sandbox/releases)

   Open the folder in terminal and run the following command

   ```bash
   # Grant execution permission to script files
   sudo chmod +x start.sh stop.sh
   ```

3. **Start the Environment**

   By running `start.sh` in following command, it will create a WordPress environment with PHP 8.1, installs WordPress core, removes the "hello" plugin, installs the "depicter" plugin at version 2.1.0, and then open the site in your browser on port 8081.

   ```sh
   ./start.sh -p 8081 --php 8.1 --auto-install --wp-plugins "-hello,+depicter@2.1.0" -b -o
   ```

   This script comes with various options to customize your WordPress setup:

   - `-p, --port` Set the local port for the WP site.
   - `-v, --volume` Set a local volume.
   - `-w, --wp-image` Set the WordPress Docker Image Tag.
   - `--php` Set the PHP version.
   - `-b, --rebuild` Trigger a rebuild of the Docker environment.
   - `-c, --clean` Mark for a fresh install (removes existing volumes).
   - `-o, --auto-open` Open the site in browser when the site is ready.
   - `--auto-install` Install WP core and plugins.
   - `--wp-cli` Install WP-CLI inside the container.
   - `--wp-plugins` Set the list of WP plugins slugs, separated by commas.
   - `--wp-user` Set the WordPress admin username.
   - `--wp-pass` Set the WordPress admin password.
   - `--wp-email` Set the WordPress admin email.


## Overview of the `start.sh` Script

The `start.sh` script is the heart of this setup, offering a variety of options to customize your WordPress Docker environment. Here's an explanation of each available option:

#### `-p, --port`

The local port on which the WordPress site will be available. Example: `-p 8082` would make your WordPress site accessible at `http://localhost:8082`.

#### `--php`

Defines the PHP version for your WordPress Docker container. Example: `--php 7.4` will setup a WordPress environment with PHP 7.4.

#### `-v, --volume`

Mounts a local volume to the Docker container. This is particularly useful for plugin or theme development. For example, `-v "./my-plugin/:/var/www/html/wp-content/plugins/my-plugin"` mounts a local directory to the plugins directory of WordPress.

#### `-w, --wp-image`

Specifies the WordPress Docker image tag. This is used if you want to specify a particular WordPress version. For instance, `-w 5.7.2-php7.4-apache` sets up WordPress version 5.7.2 with PHP 7.4.

#### `-b, --rebuild`

Rebuilds the Docker containers if they already exist. This is useful when you've made configuration changes and need to apply them.

#### `-c, --clean`

Indicates a clean installation by wiping the existing Docker volumes associated with the selected port before setting it up again.

#### `-o, --auto-open`

Automatically opens the WordPress setup in your default browser when ready.

#### `--auto-install`

Automatically installs WordPress after spinning up the Docker containers, using the details provided for admin username, password, and email.

#### `--wp-cli`

Installs WP-CLI within the WordPress Docker container. This is useful for running WordPress commands directly in the Docker environment.

#### `--wp-plugins`

Specifies plugins to install or uninstall. Prepend the plugin slug with `+` to install, `-` to uninstall. You can also specify a version for installing by appending `@<version>` to the slug. For example, `--wp-plugins "-hello,+depicter@2.1.0"` would uninstall the "hello" plugin and install "depicter" at version 2.1.0.

#### `--wp-user`, `--wp-pass`, `--wp-email`

Sets the WordPress admin username, password, and email address respectively. These are needed primarily for the `--auto-install` option.

## Usage Examples

### Starting a New WordPress Site

To start a fresh WordPress site on port 8074 with PHP version 7.4:

```bash
./start.sh -p 8074 --php 7.4 -b --clean
```

### Automatically Opening Site In Browser

To automatically open the WordPress installation after setup in your browser, add the `-o` flag:

```bash
./start.sh -p 8074 --php 7.4 -b --clean -o
```

### Setting Up Plugins On Installation

To setup WordPress with specific plugins installed or removed by default:

```bash
./start.sh -p 8080 --php 8.0 --auto-install --wp-plugins "-hello,-akismet,+depicter" -o
```

## Stopping A Site

To stop the WordPress site you can use the `stop.sh` script. For example, to stop the site running on port 8082 and remove its volumes:

```bash
./stop.sh -p 8082
```

## Stopping and REMOVING A Site

To stop and DELETE all associated Docker volumes for a specific port:

```bash
./stop.sh -p 8082 -c
```
The `-c` option triggers a volume clean up for the WordPress site.

## Fetching Repo Updates

In order to get the latest changes from this repo, run the following command in your cloned directory:

```bash
sudo chmod -x start.sh stop.sh && git pull origin && git sudo chmod +x start.sh stop.sh
```

## Additional Notes

This guide assumes familiarity with basic Docker and WordPress concepts. Make sure Docker is running on your system before executing any scripts. The flexibility of this tool means you can tailor your WordPress environment to match development needs closely, from testing plugins and themes to experimenting with different versions of WordPress and PHP.

If you encounter any issues or have further questions, feel free to open an issue in this repository.