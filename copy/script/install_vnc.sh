#!/bin/bash

# @brief: Install VNC server and noVNC for remote desktop access
# @note: This script needs root privileges to run

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
# Also install the recommended packages for VNC and noVNC
apt-get install -y --no-install-recommends \
	dbus-x11 \
	xfce4 xfce4-goodies \
	xfonts-base x11-xserver-utils \
	tigervnc-standalone-server tigervnc-common tigervnc-xorg-extension \
	novnc
apt-get clean
rm -rf /var/lib/apt/lists/*
