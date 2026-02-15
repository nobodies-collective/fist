#!/bin/sh

# Exit on errors
set -e

CONTAINER=volunteers-nowhere

echo "Building $CONTAINER ..."
docker build -t $CONTAINER .
echo "Build complete"
