#!/bin/sh

set +x

# docker stack deploy dns --compose-file docker-stack.yml
docker-compose -f docker-stack.yml up -d
