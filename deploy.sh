#!/bin/sh

set -e

docker compose pull
docker compose up -d --remove-orphans

docker ps --format '{{.Names}}' | while read -r name; do
    ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$name")
    echo "$name: $ip"
done
