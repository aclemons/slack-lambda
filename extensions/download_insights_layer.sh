#!/usr/bin/env bash

set -e

CWD="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

if ! command -v aws > /dev/null 2>&1 ; then
  >&2 printf "aws cli is required.\n"
  exit 2
fi

ARCH="${ARCH:-$(uname -m)}"

if [ "$ARCH" = "aarch64" ] ; then
  find "$CWD" -type f -name "lambda-insights-arm64-*.zip" -exec rm -rf "{}" \;
  url="$(aws lambda get-layer-version-by-arn --arn "arn:aws:lambda:eu-central-1:580247275435:layer:LambdaInsightsExtension-Arm64:5" --query 'Content.Location' --output text)"
  curl -f -s -o "$CWD/lambda-insights-arm64-5.zip" "$url"
elif [ "$ARCH" = "x86_64" ] ; then
  find "$CWD" -type f -name "lambda-insights-amd64-*.zip" -exec rm -rf "{}" \;
  url="$(aws lambda get-layer-version-by-arn --arn "arn:aws:lambda:eu-central-1:580247275435:layer:LambdaInsightsExtension:38" --query 'Content.Location' --output text)"
  curl -f -s -o "$CWD/lambda-insights-amd64-38.zip" "$url"
else
  >&2 printf "Unknown arch %s\n" "$ARCH"
  exit 3
fi
