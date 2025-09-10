#!/bin/bash

# @brief: Setup environment to build FFmpeg from source
# @details: Consult the official FFmpeg doc for the required packages
# @see: [FFmpeg Compilation Guide from official site](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu)
# @note: This script needs root privileges to run

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# === Check Ubuntu version compatibility ===
if ! grep -qE "Ubuntu 24.04" /etc/os-release; then
	echo "Error: This script is only intended for Ubuntu 24.04 LTS"
	exit 1
fi

# === Setup build environment ===
echo "=== Setting up build environment for FFmpeg..."
apt-get update
apt-get install -y \
	autoconf \
	automake \
	build-essential \
	cmake \
	git \
	libass-dev \
	libfreetype6-dev \
	libgnutls28-dev \
	libmp3lame-dev \
	libsdl2-dev \
	libtool \
	libva-dev \
	libvdpau-dev \
	libvorbis-dev \
	libxcb1-dev \
	libxcb-shm0-dev \
	libxcb-xfixes0-dev \
	meson \
	ninja-build \
	pkg-config \
	texinfo \
	wget \
	yasm \
	zlib1g-dev \
	libc6 libc6-dev \
	libnuma1 libnuma-dev
