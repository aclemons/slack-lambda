#!/usr/bin/env bash

set -e
set -o pipefail

printf 'Starting lambda handler. Running as pid %s\n' "$BASHPID"

shutdown() {
  printf 'Shutting down gracefully\n'
  exit
}
trap 'shutdown' SIGTERM

while true ; do
  HEADERS="$(mktemp)"
  curl -f -sS -LD "$HEADERS" -X GET "http://$AWS_LAMBDA_RUNTIME_API/2018-06-01/runtime/invocation/next" -o /dev/null
  REQUEST_ID="$(grep -Fi Lambda-Runtime-Aws-Request-Id "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)"
  rm -rf "$HEADERS"

  printf 'Processing request %s\n' "$REQUEST_ID"

  # TODO do work

  # Send the response
  curl -f -sS -X POST "http://$AWS_LAMBDA_RUNTIME_API/2018-06-01/runtime/invocation/$REQUEST_ID/response" -d '"OK"'
done
