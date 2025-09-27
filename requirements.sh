#!/bin/bash
## Version 1.2.4
# Fixes missing install_and_enable function and streamlines cron installation

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
    apt) dpkg -s "$1" &> /dev/null ;;
    dnf) rpm -q "$1" &> /dev/null ;;
    pacman) pacman -Q "$1" &> /dev/null ;;
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
  echo "📦 Installing cron..."

  case "$PKG_MANAGER" in
    apt)
      install_package "cron"
      sudo systemctl enable cron
      sudo systemctl start cron
      ;;
    dnf)
      install_package "cronie"
      sudo systemctl enable crond
      sudo systemctl start crond
      ;;
    pacman)
      install_package "cronie"
      sudo systemctl enable cronie
      sudo systemctl start cronie
      ;;
  esac
else
  echo "✅ cron is already installed"
fi

echo "🎉 All required packages are installed."
