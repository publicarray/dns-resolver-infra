#!/bin/sh

# set +x
# set -e

# docker run -it --rm bats/bats:latest --tap
# docker run -it -v "$PWD":/opt/bats" --workdir /opt/bats bats/bats:latest test

npm i --legacy-peer-deps

if ! command -v kdig; then
    echo "Please install knot first:"
    echo "https://www.knot-dns.cz/"
    echo "Arch: pacman -S knot"
    echo "macOS: brew install knot"
    exit 1
fi

npm run bats tests
