#!/bin/sh

# set +x
# set -e

# docker run -it --rm bats/bats:latest --tap
# docker run -it -v "$PWD":/opt/bats" --workdir /opt/bats bats/bats:latest test

npm i --legacy-peer-deps

for cmd in curl openssl; do
    if ! command -v "$cmd" >/dev/null; then
        echo "Please install $cmd first"
        exit 1
    fi
done

npm run bats tests
