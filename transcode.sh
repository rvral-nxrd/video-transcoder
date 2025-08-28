#!/bin/bash
## Version 8.2.2
# Set default verbosity level
VERBOSE=0

# Get the file path from the argument
if [ $# -gt 0 ]; then
  FILE_PATH="$1"
  # Remove trailing newline character if present
  FILE_PATH=${FILE_PATH%%[[:space:]]}
else
  echo "Error: File path not specified."
  exit 1
fi

# Transcoding process function
TRANSCODING_PROCESS() {
  # Get the file's creation date
  if [ -f "$FILE_PATH" ]; then
    DATE=$(stat -c "%y" "$FILE_PATH" | cut -d ' ' -f 1)
  else
    echo "Error: File not found - $FILE_PATH"
    exit 1
  fi
  
  # Create the output subfolder if it doesn't exist
  OUTPUT_FOLDER="${FILE_PATH%/*}/$DATE"
  mkdir -p "$OUTPUT_FOLDER"
  if [ $VERBOSE -eq 1 ]; then
    echo "Created output folder: $OUTPUT_FOLDER"
  fi

  # Transcode the video file
  OUTPUT_FILE="$OUTPUT_FOLDER/${FILE_PATH##*/}"
  OUTPUT_FILE="${OUTPUT_FILE%.*}.mov"
  echo "Transcoding file: $FILE_PATH"
  if [ $VERBOSE -eq 1 ]; then
    ffmpeg -nostdin -y -threads auto -i "$FILE_PATH" -c:v mpeg4 -q:v 10 -c:a pcm_s16le "$OUTPUT_FILE"
  else
    ffmpeg -nostdin -y -loglevel error -threads auto -i "$FILE_PATH" -c:v mpeg4 -q:v 10 -c:a pcm_s16le "$OUTPUT_FILE"
  fi

  if [ $? -eq 0 ]; then
    echo "Transcoding complete: $OUTPUT_FILE"
    rm "$FILE_PATH" && echo "Deleted original file: $FILE_PATH"
  else
    echo "Transcoding failed: $FILE_PATH"
  fi
}

# Run the transcoding process
TRANSCODING_PROCESS