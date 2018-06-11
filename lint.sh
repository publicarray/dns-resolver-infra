#!/bin/sh

# yarn
find . -not -path "./node_modules/*" -type f -name Dockerfile | xargs -L1 node_modules/.bin/dockerlint
find . -not -path "./node_modules/*" -type f -name Dockerfile | xargs -L1 node_modules/.bin/dockerfile_lint -f
