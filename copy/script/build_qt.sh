#!/bin/bash

# @brief: Build Qt6 from source, and generate a tarball of the installed Qt at /tmp/Qt-<version>.tar.xz
# @details: Consult the official Qt doc for the required packages
# @see: https://doc.qt.io/qt-6/linux-requirements.html
# @note: This script needs root privileges to run

set -euo pipefail

# @note: DO NOT create the directories `/ws/downloads` and `/ws/artifacts` in the Dockerfile, as they are expected to be mounted from the host machine.
if [[ ! -d "/ws/downloads" || ! -d "/ws/artifacts" ]]; then
	echo "WARNING: Both /ws/downloads and /ws/artifacts directories must exist to execute the 'build_qt.sh' script."
	echo "Please mount the current workspace as a volume when running the container."
	echo "But don't worry, you do not need to rebuild this image, the environment is already set up."
	echo "If you prefer custom configuration of Qt building, you can re-launch the container interactively to handle the source and build it manually."
	echo "Exiting..."
	exit 1
fi

# === Download Qt6 source code ===
echo "=== Downloading Qt6 source code..."
QT_VERSION='6.8.2'
QT_SOURCE_NAME="qt-everywhere-src-${QT_VERSION}"
QT_SOURCE_URL="https://download.qt.io/official_releases/qt/6.8/6.8.2/single/${QT_SOURCE_NAME}.tar.xz"
QT_SOURCE_TAR="/ws/downloads/${QT_SOURCE_NAME}.tar.xz"
QT_ARTIFACT_TAR="/ws/artifacts/Qt-${QT_VERSION}-install.tar.xz"

if [[ ! -f "${QT_SOURCE_TAR}" ]]; then
	wget -q ${QT_SOURCE_URL} -O ${QT_SOURCE_TAR}
else
	echo "Qt source tarball already exists at ${QT_SOURCE_TAR}, skipping download."
fi

# === Build Qt6 from source ===
echo "=== Building Qt6 from source..."
INSTALL_DIR="/opt/qt/Qt-${QT_VERSION}"
# Extract the downloaded tarball
tar -xpf ${QT_SOURCE_TAR} -C /tmp
mkdir -p /tmp/${QT_SOURCE_NAME}/build
# Configure the build
cd /tmp/${QT_SOURCE_NAME}/build
../configure -release -submodules qtbase,qtdeclarative,qtquick3d -prefix ${INSTALL_DIR} -- -Wno-dev
cmake --build . --parallel 16
# Install the built Qt6
cmake --install .

# === Create a tarball of the installed Qt ===
echo "=== Creating a tarball of the installed Qt6..."
if [[ -f "${QT_ARTIFACT_TAR}" ]]; then
	echo "Removing existing Qt6 tarball at ${QT_ARTIFACT_TAR}..."
	rm -f "${QT_ARTIFACT_TAR}"
fi
tar -cpJf ${QT_ARTIFACT_TAR} -C ${INSTALL_DIR} .

# === Bye ===
echo "=== Qt6 build and installation completed successfully!"
echo "    Check the artifacts folder for the Qt6 tarball."
