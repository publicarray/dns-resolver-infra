#!/bin/sh

set +x

docker stack deploy dns --compose-file docker-compose.yml
