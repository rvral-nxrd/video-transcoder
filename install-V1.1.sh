#!/bin/bash

# Parse options
while getopts ":d:L:" opt; do
  case $opt in
    d) DIRECTORY="$OPTARG";;
    L) LOG_FILE="$OPTARG";;
    \?) echo "Invalid option: -$OPTARG"; exit 1;;
  esac
done

# Check if directory is specified
if [ -z "$DIRECTORY" ]; then
  echo "Error: Directory not specified. Use -d flag to specify the directory."
  exit 1
fi

# Check if directory exists
if [ ! -d "$DIRECTORY" ]; then
  echo "Error: Directory '$DIRECTORY' does not exist. Creating it..."
  mkdir -p "$DIRECTORY"
  if [ $? -ne 0 ]; then
    echo "Error: Unable to create directory '$DIRECTORY'."
    exit 1
  fi
fi

# Create logs directory if custom log file is not specified
if [ -z "$LOG_FILE" ]; then
  LOGS_DIRECTORY="/var/log/transcode"
  mkdir -p "$LOGS_DIRECTORY"
  LOG_FILE="$LOGS_DIRECTORY/$(date +'%d-%m-%Y-%H%M').log"
fi

# Create transcoding script directory
TRANSCODING_SCRIPT_DIRECTORY="/transcode/scripts"
mkdir -p "$TRANSCODING_SCRIPT_DIRECTORY"

# Copy transcoding script to transcoding script directory
cp transcode-v8.1.sh "$TRANSCODING_SCRIPT_DIRECTORY/transcode.sh"
chmod +x "$TRANSCODING_SCRIPT_DIRECTORY/transcode.sh"

# Update transcoding script to use custom log file if specified
if [ -n "$LOG_FILE" ]; then
  echo "Log file: $LOG_FILE"
  # Add log file option to transcoding script command
  CRON_JOB="*/5 * * * * /bin/bash $TRANSCODING_SCRIPT_DIRECTORY/transcode.sh -d $DIRECTORY -L $LOG_FILE"
else
  CRON_JOB="*/5 * * * * /bin/bash $TRANSCODING_SCRIPT_DIRECTORY/transcode.sh -d $DIRECTORY"
fi

# Create a cron job to run the transcoding script
(crontab -l ; echo "$CRON_JOB") | crontab -

echo "Transcoding script installed successfully!"
echo "Directory: $DIRECTORY"
echo "Log file: $LOG_FILE"
echo "Transcoding script directory: $TRANSCODING_SCRIPT_DIRECTORY"