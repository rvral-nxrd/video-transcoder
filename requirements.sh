#!/bin/bash
## Version 1.2.0
# This script checks for and installs required packages for video transcoding.

REQUIRED_PACKAGES=("ffmpeg" "inotify-tools")

# Detect package manager
detect_package_manager() {
  if command -v apt &> /dev/null; then
    echo "apt"
  elif command -v dnf &> /dev/null; then
    echo "dnf"
  elif command -v pacman &> /dev/null; then
    echo "pacman"
  elif command -v apk &> /dev/null; then
    echo "apk"
  else
    echo "Unsupported package manager"
    exit 1
  fi
}

# Check if a package is installed
check_package() {
  case "$PKG_MANAGER" in
    apt)
      dpkg -s "$1" &> /dev/null
      ;;
    dnf)
      rpm -q "$1" &> /dev/null
      ;;
    pacman)
      pacman -Q "$1" &> /dev/null
      ;;
    apk)
      apk info -e "$1" &> /dev/null
      ;;
    *)
      echo "Unsupported package manager"
      exit 1
      ;;
  esac
}

# Install a package
install_package() {
  case "$PKG_MANAGER" in
    apt)
      sudo apt update
      sudo apt install -y "$1"
      ;;
    dnf)
      sudo dnf install -y "$1"
      ;;
    pacman)
      sudo pacman -Sy --noconfirm "$1"
      ;;
    apk)
      sudo apk add "$1"
      ;;
    *)
      echo "Unsupported package manager"
      exit 1
      ;;
  esac
}

# Main logic
PKG_MANAGER=$(detect_package_manager)

for package in "${REQUIRED_PACKAGES[@]}"; do
  if ! check_package "$package"; then
    echo "📦 Installing $package..."
    install_package "$package"
  else
    echo "✅ $package is already installed"
  fi
done
echo "🎉 All required packages are installed."