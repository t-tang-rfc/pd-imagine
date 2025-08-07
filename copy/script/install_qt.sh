#!/bin/bash

# @brief: Install Qt6 from a pre-built tarball
# @see: copy/script/build_qt.sh for building Qt6 from source
# @see: https://doc.qt.io/qt-6/linux-requirements.html for qt6 dev. dependencies
# @note: This script needs root privileges to run

set -euo pipefail

# === Install Qt6 from a pre-built tarball
QT_VERSION='6.8.2'
QT_ARTIFACT_TAR="/tmp/Qt-${QT_VERSION}-install.tar.xz"
QT_INSTALL_DIR="/opt/qt/Qt-${QT_VERSION}"

if [[ ! -f "$QT_ARTIFACT_TAR" ]]; then
	echo "Error: Qt tarball '$QT_ARTIFACT_TAR' not found."
	exit 1
fi

mkdir -p $QT_INSTALL_DIR
tar -xpf $QT_ARTIFACT_TAR -C $QT_INSTALL_DIR

# === Install Qt6 development dependencies
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
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

apt-get clean
rm -rf /var/lib/apt/lists/*
