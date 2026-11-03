#!/bin/sh
set -e
cd "$(dirname "$0")"

if command -v npm >/dev/null && [ -z "$TEST_WITH_DOCKER" ]; then
    for cmd in curl openssl; do
        if ! command -v "$cmd" >/dev/null; then
            echo "Please install $cmd first"
            exit 1
        fi
    done
    npm i --legacy-peer-deps
    npm run bats tests
elif command -v docker >/dev/null; then
    docker run --rm --userns=host --network host \
        -v "$PWD:/repo:ro" -v /var/run/docker.sock:/var/run/docker.sock -w /repo \
        alpine:3.24 sh -c 'apk add -q bash curl openssl bats bats-assert bats-support docker-cli && bats tests'
else
    echo "Install npm or docker to run the tests"
    exit 1
fi
