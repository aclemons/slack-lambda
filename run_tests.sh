#!/usr/bin/env bash

set -e
set -o pipefail

docker buildx build --load -t aclemons/slack-lambda:15.0 -f stable/Dockerfile --progress plain .
docker buildx build --load -t aclemons/slack-lambda:current -f current/Dockerfile --progress plain .
docker buildx build --load -t aclemons/slack-lambda:current-arm -f current/Dockerfile --progress plain .

docker compose up -d --build --wait --quiet-pull

cleanup() {
  docker compose down --remove-orphans
}
trap "cleanup" INT TERM HUP QUIT EXIT

bats tests
