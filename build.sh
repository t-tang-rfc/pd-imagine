#!/bin/bash

# @file: pd-imagine/build.sh
# @usage: bash ./build.sh <function_name>

set -euo pipefail

# === Parameters setting

DOWNLOADS='./downloads'
ARTIFACTS='./artifacts'
QT_ARTIFACT_TAR="${ARTIFACTS}/Qt-6.8.2-install.tar.xz"

# === Function Definitions

create_ros1_qt6_vnc_image() {
	# Build Docker image using Dockerfile.ros1-qt6-vnc
	if ! docker image inspect pd-imagine:ros1-qt6-vnc >/dev/null 2>&1; then
		echo "=== Building Docker image pd-imagine:ros1-qt6-vnc..."
		# Dependencies
		create_ros_noetic_dev_image
		build_qt6
		# Build the image
		docker build --network=host -f Dockerfile.ros1-qt6-vnc -t pd-imagine:ros1-qt6-vnc .
	else
		echo "[INFO] Docker image pd-imagine:ros1-qt6-vnc already exists, skipping build."
	fi
}

create_ros_noetic_dev_image() {
	# Build Docker image using Dockerfile.ros-noetic-dev
	if ! docker image inspect pd-imagine:ros-noetic-dev >/dev/null 2>&1; then
		echo "=== Building Docker image pd-imagine:ros-noetic-dev..."
		docker build --network=host -f Dockerfile.ros-noetic-dev -t pd-imagine:ros-noetic-dev .
	else
		echo "[INFO] Docker image pd-imagine:ros-noetic-dev already exists, skipping build."
	fi
}

build_qt6() {
	if [ ! -f "$QT_ARTIFACT_TAR" ]; then
		echo "=== Building Qt6 from source..."
		# Ensure the build environment is set up
		create_ubuntu20_build_qt6_image

		# Folder structure preparation
		if [ ! -d "$DOWNLOADS" ]; then
			mkdir "$DOWNLOADS"
		fi
		if [ ! -d "$ARTIFACTS" ]; then
			mkdir "$ARTIFACTS"
		fi

		# Build Qt6 using the Docker image
		docker_wksp='/wksp'
		docker run --mount "type=bind,source=$(pwd),target=$docker_wksp" pd-imagine:ubuntu20-build-qt6
	else
		echo "[INFO] Qt6 artifact tarball already exists at ${QT_ARTIFACT_TAR}, skipping build."
	fi
}

create_ubuntu20_build_qt6_image() {
	# Build Docker image using Dockerfile.ubuntu20-build-qt6
	if ! docker image inspect pd-imagine:ubuntu20-build-qt6 >/dev/null 2>&1; then
		echo "=== Building Docker image pd-imagine:ubuntu20-build-qt6..."
		docker build --network=host -f Dockerfile.ubuntu20-build-qt6 -t pd-imagine:ubuntu20-build-qt6 .
	else
		echo "[INFO] Docker image pd-imagine:ubuntu20-build-qt6 already exists, skipping build."
	fi
}

# === Helper Functions

usage() {
	echo "Usage: $0 <function_name>"
	echo "Available functions:"
	echo "  - create_ros1_qt6_vnc_image"
	echo "  - create_ros_noetic_dev_image"
	echo "  - build_qt6"
	echo "  - create_ubuntu20_build_qt6_image"
}

# === Main execution logic

# Check if a function name was provided
if [ $# -eq 0 ]; then
	usage
	exit 1
fi

# Get the function name from the first argument
FUNCTION_NAME="$1"

# Check if the function exists and call it
if declare -f "$FUNCTION_NAME" > /dev/null; then
	echo "Calling function: $FUNCTION_NAME"
	"$FUNCTION_NAME"
else
	echo "Error: Function '$FUNCTION_NAME' not found."
	usage
	exit 1
fi
