# docker-wp-sandbox
Create a fresh WordPress installtion with one simple command

### Quick start

Clone the repo on your machine
```
git clone https://github.com/M4Gd/docker-wp-sandbox.git sandbox
cd sandbox
```
Then start the containers
```
docker-compose up -d --build
```

or for more customization run:

```
WORDPRESS_VERSION=5.9-php8.0-apache && COMPOSE_PROJECT_NAME=wp8010 && WORDPRESS_SITE_PORT=8010 && WORDPRESS_DATA_DIR=./volumes/wp8010 && DATABASE_PASSWORD=EPwp8010 && MYSQL_DATA_DIR=./volumes/db8010 && docker-compose up -d --build
```

### Stop

`docker-compose down`

or for custom project names:

`COMPOSE_PROJECT_NAME=wp8010 && docker-compose down`

---

### Add new site

`sh add.sh`
