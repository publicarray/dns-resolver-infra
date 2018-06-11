#!/bin/sh

# yarn
find . -not -path "./node_modules/*" -type f -name Dockerfile | xargs -L1 node_modules/.bin/dockerlint
find . -not -path "./node_modules/*" -type f -name Dockerfile | xargs -L1 node_modules/.bin/dockerfile_lint -f

if command -v hadolint >/dev/null; then
    find . -not -path "./node_modules/*" -type f -name Dockerfile | xargs -L1 hadolint
else
    echo "For more linting install hadolint 'brew install hadolint'"
fi
