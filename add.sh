#!/bin/bash

read -p "Enter WordPress version (5.9-php8.0-apache) or latest: " WORDPRESS_VERSION
[ -z "$WORDPRESS_VERSION" ] && WORDPRESS_VERSION=5.9-php8.0-apache
echo $WORDPRESS_VERSION;
export WORDPRESS_VERSION;

read -p "Enter project name (wp8010): " APP_NAME
[ -z "$APP_NAME" ] && APP_NAME=wp8010
echo $APP_NAME;
export APP_NAME;

read -p "Enter wp site port (8010): " WORDPRESS_SITE_PORT
[ -z "$WORDPRESS_SITE_PORT" ] && WORDPRESS_SITE_PORT=8010
export WORDPRESS_SITE_PORT;

read -p "Enter database pass: " DATABASE_PASSWORD
[ -z "$DATABASE_PASSWORD" ] && DATABASE_PASSWORD="EPX6shx$APP_NAME"
export DATABASE_PASSWORD;

export WORDPRESS_DATA_DIR="./volumes/$APP_NAME"
export DATABASE_PASSWORD="EP$APP_NAME"
export MYSQL_DATA_DIR="./volumes/$APP_NAME-db"

docker-compose up -d --build