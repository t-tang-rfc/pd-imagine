#!/bin/bash

# @file: pd-imagine/build.sh
# @usage: ./build.sh <function_name>

set -euo pipefail

# === Function Definitions

create_python_dev_image() {
	# Build Docker image using Dockerfile.python-dev
	if ! docker image inspect pd-imagine:python-dev >/dev/null 2>&1; then
		echo "=== Building Docker image pd-imagine:python-dev..."
		docker build --network=host -f Dockerfile.python-dev -t pd-imagine:python-dev .
	else
		echo "[INFO] Docker image pd-imagine:python-dev already exists, skipping build."
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

create_ros_noetic_dev_image() {
	# Build Docker image using Dockerfile.ros-noetic-dev
	if ! docker image inspect pd-imagine:ros-noetic-dev >/dev/null 2>&1; then
		echo "=== Building Docker image pd-imagine:ros-noetic-dev..."
		docker build --network=host -f Dockerfile.ros-noetic-dev -t pd-imagine:ros-noetic-dev .
	else
		echo "[INFO] Docker image pd-imagine:ros-noetic-dev already exists, skipping build."
	fi
}

create_qt6_dev_vnc_image() {
	# Build Docker image using Dockerfile.qt6-dev-vnc
	if ! docker image inspect pd-imagine:qt6-dev-vnc >/dev/null 2>&1; then
		echo "=== Building Docker image pd-imagine:qt6-dev-vnc..."
		build_qt6_on_ubuntu "24.04"
		docker build --network=host -f Dockerfile.qt6-dev-vnc -t pd-imagine:qt6-dev-vnc .
	else
		echo "[INFO] Docker image pd-imagine:qt6-dev-vnc already exists, skipping build."
	fi
}

build_qt6_on_ubuntu() {
	# Accept Ubuntu version as argument (should be either 20.04 or 24.04)
	local ubuntu_version=${1:-24.04}
	local image_tag="pd-imagine:ubuntu-${ubuntu_version}-build-qt6"
	local docker_wksp='/wksp'
	local downloads='./downloads'
	local artifacts='./artifacts'
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

		create_ubuntu_build_qt6_image "$ubuntu_version" "$image_tag"
		
		# Build Qt6 using the appropriate Docker image
		docker run --mount "type=bind,source=$(pwd),target=$docker_wksp" "$image_tag"
	else
		echo "[INFO] Qt6 artifact tarball already exists at ${QT_ARTIFACT_TAR}, skipping build."
	fi
}

create_ubuntu_build_qt6_image() {
	# Accept Ubuntu version as argument (should be either 20.04 or 24.04)
	local ubuntu_version=${1}
	# Accept image tag as argument
	local image_tag=${2}
	
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
	echo "  - build_qt6_on_ubuntu [20.04|24.04] (defaults to Ubuntu 24.04)"
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
