#!/bin/bash
## Version 8.3.3
# Fixes quarantine logic to reliably move failed files and log errors

VERBOSE=0
LOG_DIR="/var/log/transcode"

# Parse optional -L flag
while [[ $# -gt 0 ]]; do
  case "$1" in
@@ -22,76 +21,62 @@ while [[ $# -gt 0 ]]; do
      ;;
  esac
done

# Validate file path
if [ -z "$FILE_PATH" ]; then
  echo "❌ Error: File path not specified."
  exit 1
fi

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
    EXIT_CODE=$?
  else
    ffmpeg -nostdin -y -loglevel error -threads auto -i "$FILE_PATH" -c:v mpeg4 -q:v 10 -c:a pcm_s16le "$TEMP_OUTPUT" 2>>"$LOG_FILE"
    EXIT_CODE=$?
  fi

  if [ $EXIT_CODE -eq 0 ]; then
    DATE=$(stat -c "%y" "$FILE_PATH" | cut -d ' ' -f 1)
    OUTPUT_FOLDER="${FILE_PATH%/*}/$DATE"
    mkdir -p "$OUTPUT_FOLDER"
    [ $VERBOSE -eq 1 ] && log "📁 Created output folder: $OUTPUT_FOLDER"

    FINAL_OUTPUT="$OUTPUT_FOLDER/$BASENAME.mov"
    mv "$TEMP_OUTPUT" "$FINAL_OUTPUT"
    log "✅ Transcoding complete: $FINAL_OUTPUT"

    rm "$FILE_PATH" && log "🗑️ Deleted original file: $FILE_PATH"
  else

    FAILED_DIR="$(dirname "$FILE_PATH")/failed"
    mkdir -p "$FAILED_DIR"

    ERROR_MSG=$(tail -n 1 "$LOG_FILE")
    [ -z "$ERROR_MSG" ] && ERROR_MSG="Unknown ffmpeg error"

    # Sidecar .fail file
    echo "$ERROR_MSG" > "$FAILED_DIR/$BASENAME.fail"

    # Running log
    echo "$(date '+%Y-%m-%d %H:%M') - $(basename "$FILE_PATH") - $ERROR_MSG" >> "$FAILED_DIR/failure.txt"

    # Move original file
    mv -n "$FILE_PATH" "$FAILED_DIR/"
    rm -f "$TEMP_OUTPUT"

    log "❌ Transcoding failed: $FILE_PATH → moved to $FAILED_DIR"
  fi
}

TRANSCODING_PROCESS