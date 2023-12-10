#!/bin/bash

sudo apt install docker-compose

env_content=$(cat <<EOF
#!/usr/bin/env bash

DEBUG=1
SECRET_KEY=thisisademosecretkey
DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]
DB_ENGINE=django.db.backends.postgresql
DB_USER=dev
DB_PASSWORD=dev
DB_HOST=db
DB_NAME=dev
DB_PORT=5432
OPENAI_API_KEY=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
EOF
)

echo "$env_content" > .env

echo ".env created"

compose_text=$(cat <<EOF
version: '3.8'

services:
  db:
    image: postgres
    restart: unless-stopped
    volumes:
      - demo_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_NAME}
      - POSTGRES_PORT= ${DB_PORT}
    ports:
      - "5432:5432"
    container_name: demo_db

  app:
    build:
      context: ./backend
      dockerfile: docker/docker_files/Dockerfile
    platform: linux/amd64
    restart: unless-stopped
    command: python manage.py runserver 0.0.0.0:8000
    ports:
      - 8000:8000
    env_file:
      - ./.env
    depends_on:
      - db
    container_name: demo_app
  
 
volumes:
  demo_data:
EOF
)

echo "$compose_text" > docker-compose.yml


echo "docker yml created"

echo "Environment variables inserted into .env file."

settings_file="backend/django_chatgpt/settings.py"

# Replace the ALLOWED_HOSTS line with the new value ['*']
sed -i "s/^ALLOWED_HOSTS = .*/ALLOWED_HOSTS = ['*']/" "$settings_file"

echo "ALLOWED_HOSTS set to ['*'] in $settings_file"

sudo docker-compose up -d --build