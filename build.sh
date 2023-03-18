#!/bin/sh

set +x

docker compose build
docker compose push
