#!/bin/bash
## Version 8.3.1
# Lazy folder creation using .cache directory to avoid empty folders on failure

VERBOSE=0
LOG_DIR="/var/log/transcode"

# Parse optional -L flag
while [[ $# -gt 0 ]]; do
  case "$1" in
    -L)
      LOG_DIR="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      FILE_PATH="$1"
      shift
      ;;
  esac
done

# Validate file path
if [ -z "$FILE_PATH" ]; then
  echo "❌ Error: File path not specified."
  exit 1
fi

# Remove trailing whitespace
FILE_PATH=${FILE_PATH%%[[:space:]]}

# Create log file with timestamp
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$TIMESTAMP.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

TRANSCODING_PROCESS() {
  if [ ! -f "$FILE_PATH" ]; then
    log "❌ Error: File not found - $FILE_PATH"
    exit 1
  fi

  EXT="${FILE_PATH##*.}"
  BASENAME="$(basename "$FILE_PATH" ."$EXT")"
  CACHE_DIR="$(dirname "$FILE_PATH")/.cache"
  mkdir -p "$CACHE_DIR"

  TEMP_OUTPUT="$CACHE_DIR/$BASENAME.mov"
  log "🎬 Transcoding file: $FILE_PATH"

  if [ $VERBOSE -eq 1 ]; then
    ffmpeg -nostdin -y -threads auto -i "$FILE_PATH" -c:v mpeg4 -q:v 10 -c:a pcm_s16le "$TEMP_OUTPUT" 2>>"$LOG_FILE"
  else
    ffmpeg -nostdin -y -loglevel error -threads auto -i "$FILE_PATH" -c:v mpeg4 -q:v 10 -c:a pcm_s16le "$TEMP_OUTPUT" 2>>"$LOG_FILE"
  fi

  if [ $? -eq 0 ]; then
    DATE=$(stat -c "%y" "$FILE_PATH" | cut -d ' ' -f 1)
    OUTPUT_FOLDER="${FILE_PATH%/*}/$DATE"
    mkdir -p "$OUTPUT_FOLDER"
    [ $VERBOSE -eq 1 ] && log "📁 Created output folder: $OUTPUT_FOLDER"

    FINAL_OUTPUT="$OUTPUT_FOLDER/$BASENAME.mov"
    mv "$TEMP_OUTPUT" "$FINAL_OUTPUT"
    log "✅ Transcoding complete: $FINAL_OUTPUT"

    rm "$FILE_PATH" && log "🗑️ Deleted original file: $FILE_PATH"
  else
    rm -f "$TEMP_OUTPUT"
    log "❌ Transcoding failed: $FILE_PATH"
  fi
}

TRANSCODING_PROCESS
