#!/bin/bash

read -p "Enter project name (wp8010): " APP_NAME
[ -z "$APP_NAME" ] && APP_NAME=wp8010
echo $APP_NAME;
export APP_NAME;

docker-compose down