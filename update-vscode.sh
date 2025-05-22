#!/bin/bash

# Define download URL and target file name
URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
TAR_FILE="code-$(date +%Y-%m-%d).tar.gz"

# Download the tarball
wget -O "$TAR_FILE" "$URL"
if [ $? -ne 0 ]; then
  echo "Download failed."
  exit 1
fi

# Untar the tarball
tar -xvf "$TAR_FILE"
if [ $? -ne 0 ]; then
  echo "Extraction failed."
  exit 1
fi

# Find the extracted folder (assuming it starts with "VSCode")
EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "VSCode-linux*" | head -n 1)
if [ -z "$EXTRACTED_DIR" ]; then
  echo "Failed to locate the extracted VSCode directory."
  exit 1
fi

# Delete the existing code directory and the tarball
rm -rf ~/share/code "$TAR_FILE"

# Move the extracted directory to the share directory
mv "$EXTRACTED_DIR" ~/share/code
if [ $? -eq 0 ]; then
  echo "VSCode updated successfully!"
else
  echo "Failed to move the directory."
  exit 1
fi
