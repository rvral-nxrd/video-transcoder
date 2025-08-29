#!/bin/bash
## Version 1.0.0
# This script checks for and installs required packages for video transcoding.
# Function to check if a package is installed
check_package() {
  if command -v dpkg &> /dev/null; then
    dpkg -s "$1" &> /dev/null
  elif command -v rpm &> /dev/null; then
    rpm -q "$1" &> /dev/null
  else
    echo "Unsupported package manager"
    exit 1
  fi
}

# Function to install a package
install_package() {
  if command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y "$1"
  elif command -v dnf &> /dev/null; then
    sudo dnf install -y "$1"
  else
    echo "Unsupported package manager"
    exit 1
  fi
}

# Check and install required packages
REQUIRED_PACKAGES=("ffmpeg" "inotify-tools")

for package in "${REQUIRED_PACKAGES[@]}"; do
  if ! check_package "$package"; then
    echo "Installing $package..."
    install_package "$package"
  else
    echo "$package is already installed"
  fi
done