#!/bin/bash

read -p "Enter project name (wp8010): " COMPOSE_PROJECT_NAME
[ -z "$COMPOSE_PROJECT_NAME" ] && COMPOSE_PROJECT_NAME=wp8010
echo $COMPOSE_PROJECT_NAME;

docker-compose down