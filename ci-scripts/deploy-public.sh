#!/bin/bash
set -e

docker push aztec/$1:latest
if [ -n "$CIRCLE_SHA1" ]; then
  docker push aztec/$1:$CIRCLE_SHA1
fi