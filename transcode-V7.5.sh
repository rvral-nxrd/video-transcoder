#!/bin/bash

# Set default verbosity level
VERBOSE=0

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Get the file path from the argument
if [ $# -gt 0 ]; then
  FILE_PATH="$1"
  # Remove trailing newline character if present
  FILE_PATH=${FILE_PATH%%[[:space:]]}
else
  # Get the current working directory
  INPUT_FOLDER=$(pwd)
  # Find video files in the input folder
  find "$INPUT_FOLDER" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" -o -name "*.ts" \) -print0 | while IFS= read -r -d '' FILE_PATH; do
    # Run the transcoding process
    TRANSCODING_PROCESS
  done
  exit 0
fi

# Set log file
LOG_FILE="/transcode/logs/logs-$(date +'%Y-%m-%d_%H%M').txt"
mkdir -p "/transcode/logs"
exec > >(tee -a "$LOG_FILE") 2>&1

# Transcoding process function
TRANSCODING_PROCESS() {
  # Get the file's creation date
  DATE=$(stat -c "%y" "$FILE_PATH" | cut -d ' ' -f 1)
  # Create the output subfolder if it doesn't exist
  OUTPUT_FOLDER="${FILE_PATH%/*}/$DATE"
  mkdir -p "$OUTPUT_FOLDER"
  if [ $VERBOSE -eq 1 ]; then
    echo -e "${YELLOW}Created output folder: $OUTPUT_FOLDER${NC}"
  fi
  # Transcode the video file
  OUTPUT_FILE="$OUTPUT_FOLDER/${FILE_PATH##*/}"
  OUTPUT_FILE="${OUTPUT_FILE%.*}.mov"
  echo -e "${GREEN}Transcoding file: $FILE_PATH${NC}"
  if [ $VERBOSE -eq 1 ]; then
    ffmpeg -nostdin -y -threads auto -i "$FILE_PATH" -c:v mpeg4 -q:v 10 -c:a pcm_s16le "$OUTPUT_FILE"
  else
    ffmpeg -nostdin -y -loglevel error -threads auto -i "$FILE_PATH" -c:v mpeg4 -q:v 10 -c:a pcm_s16le "$OUTPUT_FILE"
  fi
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Transcoding complete: $OUTPUT_FILE${NC}"
    rm "$FILE_PATH" && echo -e "${YELLOW}Deleted original file: $FILE_PATH${NC}"
  else
    echo -e "${RED}Transcoding failed: $FILE_PATH${NC}"
  fi
}

# Run the transcoding process
TRANSCODING_PROCESS
