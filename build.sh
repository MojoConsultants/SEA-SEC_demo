#!/bin/bash

# File to store the current version
VERSION_FILE="version.txt"

# Read the current version from the file (default to 1.0 if the file doesn't exist)
if [ ! -f "$VERSION_FILE" ]; then
  echo "1.0" > "$VERSION_FILE"
fi
VERSION=$(cat "$VERSION_FILE")

# Build the Docker image with the versioned tag, passing VERSION as build-arg
IMAGE_NAME="SEASEQ_Image_V${VERSION}"
docker build --build-arg VERSION=$VERSION -t $IMAGE_NAME .

# Increment the version (e.g., 1.0 -> 1.1)
NEW_VERSION=$(echo "$VERSION + 0.1" | bc)
echo "$NEW_VERSION" > "$VERSION_FILE"

# Run the container with the versioned name
CONTAINER_NAME="SEASEQ_Container_V${VERSION}"
docker run --name $CONTAINER_NAME -d -p 8000:8000 $IMAGE_NAME

# Output the details
echo "Built and ran container:"
echo "  Image: $IMAGE_NAME"
echo "  Container: $CONTAINER_NAME"
