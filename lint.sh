#!/bin/sh

find . -not -path "./node_modules/*" -type f -name Dockerfile | while read -r f; do
    echo "==> docker build --check $f"
    docker build --check -f "$f" "$(dirname "$f")"
done

if command -v hadolint >/dev/null; then
    find . -not -path "./node_modules/*" -type f -name Dockerfile -exec hadolint {} +
elif command -v docker >/dev/null; then
    find . -not -path "./node_modules/*" -type f -name Dockerfile | while read -r f; do
        echo "==> hadolint $f"
        docker run --rm -i hadolint/hadolint < "$f"
    done
else
    echo "Install hadolint for deeper linting: pacman -S hadolint"
fi
