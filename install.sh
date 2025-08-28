#!/bin/bash
## Version 1.4.1
# Parse options
while getopts ":d:L:-:" opt; do
  case $opt in
    d) DIRECTORY="$OPTARG";;
    L) LOG_FILE="$OPTARG";;
    -) 
      case $OPTARG in
        uninstall) UNINSTALL=1;;
      esac
      ;;
    \?) echo "Invalid option: -$OPTARG"; exit 1;;
  esac
done

# Check if uninstall flag is set
if [ "$UNINSTALL" = "1" ]; then
  # Stop and disable the service
  systemctl stop transcode.service
  systemctl disable transcode.service
  
  # Remove the service file
  rm /etc/systemd/system/transcode.service
  
  # Remove the transcoding script directory
  rm -rf /transcode/scripts
  
  # Remove the log files
  rm -rf /var/log/transcode
  
  # Reload systemd daemon
  systemctl daemon-reload
  
  echo "Uninstallation complete."
  exit 0
fi

# Check if directory is specified
if [ -z "$DIRECTORY" ]; then
  echo "Error: Directory not specified. Use -d flag to specify the directory."
  exit 1
fi

# Create transcoding script directory
mkdir -p /transcode/scripts

# Copy transcoding script to transcoding script directory
cp transcode.sh /transcode/scripts/
chmod +x /transcode/scripts/transcode.sh

# Create service file
cat << EOF > /etc/systemd/system/transcode.service
[Unit]
Description=Video Transcoder Service
After=network.target

[Service]
User=$(whoami)
ExecStart=/bin/bash -c '/usr/bin/inotifywait -m $DIRECTORY -e close_write --format "%w%f" 2>&1 | tee -a /var/log/transcode/inotify.log | while read -r filename; do /transcode/scripts/transcode.sh "$DIRECTORY$filename"; done'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
systemctl daemon-reload

# Enable and start the service
systemctl enable transcode.service
systemctl start transcode.service

echo "Transcoding service installed successfully!"
echo "Directory: $DIRECTORY"