#!/bin/bash

# @brief: Setup environment to build Qt6 from source
# @details: Consult the official Qt doc for the required packages
# @see: https://doc.qt.io/qt-6/linux-requirements.html
# @note: This script needs root privileges to run

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
# === Setup build environment ===
echo "=== Setting up build environment for Qt6..."
apt-get update
apt-get install -y --no-install-recommends \
	wget gnupg ca-certificates
# @note:
# - Default cmake version on Ubuntu 20.04 is too old for Qt6, you need to install a newer version from Kitware's apt repository.
# - But at the same time, you would better pin the version to a reasonable one (here a version that is equivalent to the default of Ubuntu 24.04) to avoid bleeding-edge versions (like 4.0+), which may highly likely break compatibility of other components of your project.
CMAKE_VERSION='3.28.6-0kitware1ubuntu20.04.1'
if grep -q "Ubuntu 20.04" /etc/os-release; then
	# Install Kitware's apt repository for newer CMake
	# @see: https://apt.kitware.com/
	wget -qO- https://apt.kitware.com/keys/kitware-archive-latest.asc  | gpg --dearmor > /usr/share/keyrings/kitware-archive-keyring.gpg
	echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list > /dev/null
	apt-get update
fi
apt-get install -y --no-install-recommends \
	build-essential \
	cmake-data=$CMAKE_VERSION cmake=$CMAKE_VERSION \
	ninja-build \
	python3 \
	libfontconfig1-dev \
	libfreetype-dev \
	libgtk-3-dev \
	libx11-dev \
	libx11-xcb-dev \
	libxcb-cursor-dev \
	libxcb-glx0-dev \
	libxcb-icccm4-dev \
	libxcb-image0-dev \
	libxcb-keysyms1-dev \
	libxcb-randr0-dev \
	libxcb-render-util0-dev \
	libxcb-shape0-dev \
	libxcb-shm0-dev \
	libxcb-sync-dev \
	libxcb-util-dev \
	libxcb-xfixes0-dev \
	libxcb-xkb-dev \
	libxcb1-dev \
	libxext-dev \
	libxfixes-dev \
	libxi-dev \
	libxkbcommon-dev \
	libxkbcommon-x11-dev \
	libxrender-dev
