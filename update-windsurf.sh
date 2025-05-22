#!/bin/bash

# Define API URL
API_URL="https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest"
INSTALL_DIR="$HOME/share/Windsurf"  # Use $HOME for reliability
TMP_DIR="/tmp/windsurf-update"  # Use /tmp for temporary files

# Create the temporary directory if it doesn't exist
mkdir -p "$TMP_DIR"

# Download the JSON data
JSON_DATA=$(curl -s "$API_URL")

if [ $? -ne 0 ]; then
  echo "Failed to download JSON data."
  exit 1
fi

# Extract the download link and filename from the JSON data using jq
DOWNLOAD_URL=$(echo "$JSON_DATA" | jq -r '.url')

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Failed to extract download URL from JSON."
  exit 1
fi

FILENAME=$(basename "$DOWNLOAD_URL")

if [ -z "$FILENAME" ]; then
    echo "Failed to extract filename from the URL."
    exit 1
fi

TAR_FILE="$FILENAME"

# Download the tarball
wget -O "$TMP_DIR/$TAR_FILE" "$DOWNLOAD_URL"
if [ $? -ne 0 ]; then
  echo "Download failed."
  exit 1
fi

# Untar the tarball
tar -xvf "$TMP_DIR/$TAR_FILE" -C "$TMP_DIR"
if [ $? -ne 0 ]; then
  echo "Extraction failed."
  exit 1
fi

# Directly define the extracted directory as "Windsurf" inside the TMP_DIR
EXTRACTED_DIR="$TMP_DIR/Windsurf"

# Check if the expected directory exists
if [ ! -d "$EXTRACTED_DIR" ]; then
  echo "Expected 'Windsurf' directory not found in the extracted archive."
  exit 1
fi

# Check if the extracted directory is empty
shopt -s nullglob  # Ensure glob expands to nothing if no matches
FILES=("$EXTRACTED_DIR/*")
shopt -u nullglob  # Disable nullglob
NUM_FILES="${#FILES[@]}"

if [ "$NUM_FILES" -eq 0 ]; then
  echo "The extracted 'Windsurf' directory is empty."
  ls -l "$EXTRACTED_DIR"  # List contents of the directory (if any)
  tar -tf "$TMP_DIR/$TAR_FILE" # List the content of the tar file to confirm the files are actually there
  exit 1
fi


# Backup the existing installation directory, if it exists
if [ -d "$INSTALL_DIR" ]; then
  BACKUP_DIR="$HOME/share/windsurf_backup"
  echo "Backing up existing installation to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  mv "$INSTALL_DIR" "$BACKUP_DIR/windsurf_$(date +%Y-%m-%d_%H-%M-%S)"
fi

# Move the contents of the extracted directory to the installation directory
mv "$EXTRACTED_DIR" "$INSTALL_DIR"
if [ $? -eq 0 ]; then
  echo "Windsurf updated successfully!"
else
  echo "Failed to move the directory contents."
  exit 1
fi

# Clean up temporary files
rm -rf "$TMP_DIR"
echo "Cleaned up temporary files."

exit 0
