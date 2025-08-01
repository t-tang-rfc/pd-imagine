#!/bin/bash

# @file: pd-imagine/build.sh

set -euo pipefail

DOWNLOADS='./downloads'
ARTIFACTS='./artifacts'
# Folder structure preparation
if [ ! -d "$DOWNLOADS" ]; then
	mkdir "$DOWNLOADS"
fi
if [ ! -d "$ARTIFACTS" ]; then
	mkdir "$ARTIFACTS"
fi

# Build Docker image using Dockerfile.ubuntu
docker build -f Dockerfile.ubuntu20-build-qt6 -t pd-imagine:ubuntu20-build-qt6 .

docker run --mount "type=bind,source=$(pwd),target=/ws" pd-imagine:ubuntu20-build-qt6
