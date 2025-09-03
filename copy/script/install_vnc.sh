#!/bin/bash

# @brief: Install VNC server and noVNC for remote desktop access
# @note: This script needs root privileges to run

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
# Also install the recommended packages for VNC and noVNC
apt-get install -y \
	dbus-x11 \
	xfce4 xfce4-goodies \
	tigervnc-standalone-server \
	novnc

apt-get clean
rm -rf /var/lib/apt/lists/*
