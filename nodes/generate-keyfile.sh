#!/bin/bash

set -e

# Path to the keyfile and database directory
KEYFILE_PATH="/data/keyfile"
DB_PATH="/data/db"

# Function to log with timestamp
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if the keyfile already exists
if [ -f "$KEYFILE_PATH" ]; then
  log "Keyfile already exists at $KEYFILE_PATH. Verifying permissions."
  chown mongodb:mongodb "$KEYFILE_PATH"
  chmod 600 "$KEYFILE_PATH"
else
  # Generate the keyfile from the environment variable
  if [ -z "$KEYFILE" ]; then
    log "ERROR: KEYFILE environment variable is not set. Exiting."
    exit 1
  fi

  log "Generating keyfile from environment variable..."
  echo "$KEYFILE" > "$KEYFILE_PATH"
  chown mongodb:mongodb "$KEYFILE_PATH"
  chmod 600 "$KEYFILE_PATH"
  log "Keyfile generated successfully."
fi

# Ensure the database directory exists and has correct permissions
if [ ! -d "$DB_PATH" ]; then
  log "Creating MongoDB data directory at $DB_PATH..."
  mkdir -p "$DB_PATH"
fi

chown -R mongodb:mongodb "$DB_PATH"
log "Database directory permissions set."

# Validate keyfile
if [ ! -s "$KEYFILE_PATH" ]; then
  log "ERROR: Keyfile is empty or invalid."
  exit 1
fi

log "MongoDB node initialization completed successfully."
