#!/bin/bash

# Read the current version from a file (or set a default)
VERSION_FILE="version.txt"
if [ ! -f "$VERSION_FILE" ]; then
  echo "1.0" > "$VERSION_FILE"
fi

VERSION=$(cat "$VERSION_FILE")

# Build the image
docker build -t SEASEQ_Image_V${VERSION} .

# Increment the version
NEW_VERSION=$(echo "$VERSION + 0.1" | bc)
echo "$NEW_VERSION" > "$VERSION_FILE"
echo "Built SEASEQ_Image_V${VERSION} and updated version to ${NEW_VERSION}" 
# Note: Ensure you have Docker installed and running to execute this script successfully.
