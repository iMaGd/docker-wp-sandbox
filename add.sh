#!/bin/bash

read -p "Enter WordPress version (5.9-php8.0-apache) or latest: " WORDPRESS_VERSION
[ -z "$WORDPRESS_VERSION" ] && WORDPRESS_VERSION=5.9-php8.0-apache
echo $WORDPRESS_VERSION;

read -p "Enter project name (wp8010): " COMPOSE_PROJECT_NAME
[ -z "$COMPOSE_PROJECT_NAME" ] && COMPOSE_PROJECT_NAME=wp8010
echo $COMPOSE_PROJECT_NAME;

read -p "Enter wp site port (8010): " WORDPRESS_SITE_PORT
[ -z "$WORDPRESS_SITE_PORT" ] && WORDPRESS_SITE_PORT=8010

read -p "Enter database pass: " DATABASE_PASSWORD
[ -z "$DATABASE_PASSWORD" ] && DATABASE_PASSWORD="EPX6shx$COMPOSE_PROJECT_NAME"

WORDPRESS_DATA_DIR="./volumes/$COMPOSE_PROJECT_NAME"
DATABASE_PASSWORD="EP$COMPOSE_PROJECT_NAME"
MYSQL_DATA_DIR="./volumes/db_$COMPOSE_PROJECT_NAME"

docker-compose up -d --build