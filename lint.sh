#!/bin/sh

# yarn
find . -type f -name Dockerfile | xargs -L1 yarn dockerlint
find . -type f -name Dockerfile | xargs -L1 yarn dockerfile_lint -f
