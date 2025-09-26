#!/bin/bash
## Version 1.2.3
# This script checks for and installs required packages for video transcoding.
# Alpine support has been removed.

REQUIRED_PACKAGES=("ffmpeg" "inotify-tools")

# Detect package manager
detect_package_manager() {
  if command -v apt &> /dev/null; then
    echo "apt"
  elif command -v dnf &> /dev/null; then
    echo "dnf"
  elif command -v pacman &> /dev/null; then
    echo "pacman"
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

# Check and install cron
if ! command -v crontab &> /dev/null; then
  case "$PKG_MANAGER" in
    apt) install_and_enable "cron" "cron" ;;
    dnf) install_and_enable "cronie" "crond" ;;
    pacman) install_and_enable "cronie" "cronie" ;;
  esac
else
  echo "✅ cron is already installed"
fi

echo "🎉 All required packages are installed."
