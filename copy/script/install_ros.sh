#!/bin/bash

# @brief: Install ROS 1 Noetic
# @details: ROS Noetic will be installed to `/opt/ros/noetic`
# @note: Consult the docker hub for ROS official image and GitHub for source of those images.
# @see: 
# - https://hub.docker.com/_/ros/tags?name=noetic
# - https://github.com/osrf/docker_images/tree/master/ros/noetic/ubuntu/focal
# @note: This script needs root privileges to run

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export TZ='Asia/Tokyo'
export LANG='C.UTF-8'
export LC_ALL='C.UTF-8'
export ROS_DISTRO=noetic
apt-get update
apt-get install -y --no-install-recommends \
	wget gnupg ca-certificates \
	tzdata
# === Install ROS Noetic Base ===
# Setup keys
wget -qO- 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x4B63CF8FDE49746E98FA01DDAD19BAB3CBF125EA' | gpg --dearmor > /usr/share/keyrings/ros1-snapshots-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/ros1-snapshots-archive-keyring.gpg] http://snapshots.ros.org/noetic/final/ubuntu focal main' > /etc/apt/sources.list.d/ros1-snapshots.list
apt-get update
# Install ros base packages and tools
apt-get install -y --no-install-recommends \
	ros-$ROS_DISTRO-ros-base \
	ros-$ROS_DISTRO-joy \
	build-essential \
	python3 \
	python3-rosdep \
	python3-rosinstall \
	python3-vcstools \
	libeigen3-dev
# Update rosdep
rosdep init
rosdep update
