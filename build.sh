#!/bin/bash

# @file: pd-imagine/build.sh
# @usage: ./build.sh <function_name>

set -euo pipefail

# === Function Definitions

create_python_dev_image() {
	local image_name="pd-imagine/python-dev:latest"
	local remote_image="ghcr.io/madpang/pd-imagine/python-dev:latest"
	
	# Check if local image already exists
	if docker image inspect "$image_name" >/dev/null 2>&1; then
		echo "[INFO] Docker image $image_name already exists, skipping build."
		return
	fi
	
	# Try to pull from GitHub Container Registry first
	echo "=== Attempting to pull $remote_image..."
	if docker image pull "$remote_image" >/dev/null 2>&1; then
		echo "[INFO] Successfully pulled $remote_image"
		echo "=== Tagging as local image $image_name..."
		docker image tag "$remote_image" "$image_name"
		echo "[INFO] Tagged $remote_image as $image_name"
	else
		echo "[INFO] Failed to pull $remote_image, building locally..."
		echo "=== Building Docker image $image_name..."
		docker build --network=host -f Dockerfile.python-dev -t "$image_name" .
	fi
}

create_ros1_qt6_vnc_image() {
	local image_name="pd-imagine/ros1-qt6-vnc:latest"
	# Build Docker image using Dockerfile.ros1-qt6-vnc
	if ! docker image inspect "$image_name" >/dev/null 2>&1; then
		echo "=== Building Docker image $image_name..."
		# Dependencies
		create_ros_noetic_dev_image
		build_qt6_on_ubuntu "20.04"
		# Build the image
		docker build --network=host -f Dockerfile.ros1-qt6-vnc -t "$image_name" .
	else
		echo "[INFO] Docker image $image_name already exists, skipping build."
	fi
}

create_qt6_dev_vnc_image() {
	local image_name="pd-imagine/qt6-dev-vnc:latest"
	# Build Docker image using Dockerfile.qt6-dev-vnc
	if ! docker image inspect "$image_name" >/dev/null 2>&1; then
		echo "=== Building Docker image $image_name..."
		build_qt6_on_ubuntu "24.04"
		docker build --network=host -f Dockerfile.qt6-dev-vnc -t "$image_name" .
	else
		echo "[INFO] Docker image $image_name already exists, skipping build."
	fi
}

create_ros_noetic_dev_image() {
	local image_name="pd-imagine/ros-noetic-dev:latest"
	local remote_image="ghcr.io/madpang/pd-imagine/ros-noetic-dev:latest"
	
	# Check if local image already exists
	if docker image inspect "$image_name" >/dev/null 2>&1; then
		echo "[INFO] Docker image $image_name already exists, skipping build."
		return
	fi
	
	# Try to pull from GitHub Container Registry first
	echo "=== Attempting to pull $remote_image..."
	if docker image pull "$remote_image" >/dev/null 2>&1; then
		echo "[INFO] Successfully pulled $remote_image"
		echo "=== Tagging as local image $image_name..."
		docker image tag "$remote_image" "$image_name"
		echo "[INFO] Tagged $remote_image as $image_name"
	else
		echo "[INFO] Failed to pull $remote_image, building locally..."
		echo "=== Building Docker image $image_name..."
		docker build --network=host -f Dockerfile.ros-noetic-dev -t "$image_name" .
	fi
}

build_qt6_on_ubuntu() {
	# @param[in]: Ubuntu version, should be either 20.04 or 24.04
	local ubuntu_version=${1:-24.04}
	# Derived variables (@note: MUST match that in )
	local image_tag="pd-imagine/ubuntu-build-qt6:latest"
	# Fixed variables
	local downloads='./downloads'
	local artifacts='./artifacts'
	local docker_wksp='/wksp'
	# @note: The artifact tarball name should match that in the `build_qt.sh` script
	local QT_ARTIFACT_TAR="${artifacts}/Qt-6.8.2-install.tar.xz"

	if [ ! -f "$QT_ARTIFACT_TAR" ]; then
		echo "=== Building Qt6 from source using Ubuntu ${ubuntu_version}..."
		# Folder structure preparation
		if [ ! -d "$downloads" ]; then
			mkdir "$downloads"
		fi
		if [ ! -d "$artifacts" ]; then
			mkdir "$artifacts"
		fi
		# Ensure the build environment is set up based on version
		create_ubuntu_build_qt6_image "$ubuntu_version"
		# Build Qt6 using the appropriate Docker image
		docker run --mount "type=bind,source=$(pwd),target=$docker_wksp" "$image_tag"
	else
		echo "[INFO] Qt6 artifact tarball already exists at ${QT_ARTIFACT_TAR}, skipping build."
	fi
}

create_ubuntu_build_qt6_image() {
	# @param[in]: Ubuntu version, should be either 20.04 or 24.04
	# @note: This parameter will be passed to the Docker build as a build-arg
	local ubuntu_version=${1:-24.04}
	if [[ "$ubuntu_version" != "20.04" && "$ubuntu_version" != "24.04" ]]; then
		echo "Error: Unsupported Ubuntu version '$ubuntu_version'. Supported versions are 20.04 and 24.04."
		exit 1
	fi
	# Derived variables
	local image_tag="pd-imagine/ubuntu-build-qt6:latest"
	
	# Build Docker image using Dockerfile.ubuntu-build-qt6
	if ! docker image inspect "$image_tag" >/dev/null 2>&1; then
		echo "=== Building Docker image $image_tag..."
		docker build --network=host --build-arg UBUNTU_VERSION="$ubuntu_version" -f Dockerfile.ubuntu-build-qt6 -t "$image_tag" .
	else
		echo "[INFO] Docker image $image_tag already exists, skipping build."
	fi
}

# === Helper Functions

usage() {
	echo "Usage: $0 <function_name>"
	echo "Available functions:"
	echo "  - create_python_dev_image"
	echo "  - create_qt6_dev_vnc_image"
	echo "  - create_ros1_qt6_vnc_image"
	echo "  - create_ros_noetic_dev_image"
	echo "  - create_ubuntu_build_qt6_image [24.04|20.04] (defaults to Ubuntu 24.04)"
	echo "  - build_qt6_on_ubuntu [24.04|20.04] (defaults to Ubuntu 24.04)"
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
