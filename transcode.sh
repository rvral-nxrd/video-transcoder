#!/bin/bash
## Version 8.2
# Set default verbosity level
VERBOSE=0

# Parse options
while getopts ":d:L:v" opt; do
  case $opt in
    # use -d and a path to specify the directory to monitor
    d) DIRECTORY="$OPTARG";;
    # use -L and a path to log output to a file
    L) LOG_FILE="$OPTARG";;
    # use -v for verbose output
    v) VERBOSE=1;;
    \?) echo "Invalid option: -$OPTARG"; exit 1;;
  esac
done

# Check if directory is specified
if [ -z "$DIRECTORY" ]; then
  echo "Error: Directory not specified. Use -d flag to specify the directory."
  exit 1
fi

# Set up logging if LOG_FILE is specified
if [ -n "$LOG_FILE" ]; then
  mkdir -p "$(dirname "$LOG_FILE")"
  exec > >(tee -a "$LOG_FILE") 2>&1
fi

# Get the file path from the argument
if [ $# -gt 0 ]; then
  FILE_PATH="$1"
  # Remove trailing newline character if present
  FILE_PATH=${FILE_PATH%%[[:space:]]}
else
  # Get the current working directory
  INPUT_FOLDER="$DIRECTORY"
  # Find video files in the input folder
  find "$INPUT_FOLDER" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" -o -name "*.ts" \) -print0 | while IFS= read -r -d '' FILE_PATH; do
    # Run the transcoding process
    TRANSCODING_PROCESS
  done
  exit 0
fi

# Transcoding process function
TRANSCODING_PROCESS() {
  # Get the file's creation date
  DATE=$(stat -c "%y" "$FILE_PATH" | cut -d ' ' -f 1)
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