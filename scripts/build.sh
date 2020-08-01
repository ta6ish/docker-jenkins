#!/usr/bin/env bash
set -e
COMMIT=$(git rev-parse HEAD)
echo "Building $COMMIT inside $(pwd)"

docker build -t nodeapp/"$BRANCH_NAME":latest .
docker build -t nodeapp/"$BRANCH_NAME":$COMMIT .