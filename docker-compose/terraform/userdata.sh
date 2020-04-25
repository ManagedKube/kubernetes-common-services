#!/bin/bash
mkdir -p /app
cd /app

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /app/docker-compose

sudo chmod +x /app/docker-compose

# Pull repo

git clone --branch docker-compose https://github.com/ManagedKube/kubernetes-common-services.git

cd kubernetes-common-services/docker-compose

# Start docker compose
/app/docker-compose build
/app/docker-compose up
