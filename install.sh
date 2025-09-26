#!/bin/bash
## Version 1.5.2
## improved file and directory handling with inotifywait

set -e  # Exit on any error

# Default values
UNINSTALL=0
LOG_FILE=""

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d)
      DIRECTORY="$2"
      shift 2
      ;;
    -L)
      LOG_FILE="$2"
      shift 2
      ;;
    --uninstall)
      UNINSTALL=1
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [-d directory] [-L log_file] [--uninstall]"
      exit 0
      ;;
    *)
      echo "Invalid option: $1"
      exit 1
      ;;
  esac
done

# Uninstallation logic
if [ "$UNINSTALL" = "1" ]; then
  echo "Uninstalling transcoding service..."

  sudo systemctl stop transcode.service || true
  sudo systemctl disable transcode.service || true
  sudo rm -f /etc/systemd/system/transcode.service
  sudo rm -rf /transcode/scripts
  sudo rm -rf /var/log/transcode
  sudo systemctl daemon-reload

  echo "✅ Uninstallation complete."
  exit 0
fi

# Validate directory input
if [ -z "$DIRECTORY" ]; then
  echo "❌ Error: Directory not specified. Use -d to specify the directory."
  exit 1
fi

# Check for requirements.sh
if [ ! -f requirements.sh ]; then
  echo "❌ Error: requirements.sh not found."
  exit 1
fi

# Source requirements
source requirements.sh

# Create necessary directories
sudo mkdir -p /transcode/scripts
sudo mkdir -p /var/log/transcode

# Copy and set permissions for transcoding script
sudo cp transcode.sh /transcode/scripts/
sudo chmod +x /transcode/scripts/transcode.sh

# Create systemd service file
sudo tee /etc/systemd/system/transcode.service > /dev/null << EOF
[Unit]
Description=Video Transcoder Service
After=network.target

[Service]
User=$(logname)
ExecStart=/bin/bash -c "/usr/bin/inotifywait -m -e close_write,moved_to --format '%w%f' $DIRECTORY | while read -r filepath; do /transcode/scripts/transcode.sh \"\$filepath\"; done"t a
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload and start service
sudo systemctl daemon-reload
sudo systemctl enable transcode.service
sudo systemctl start transcode.service

echo "✅ Transcoding service installed successfully!"
echo "Watching directory: $DIRECTORY"