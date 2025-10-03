#!/bin/bash
VERSION=$(cat version.txt)  # or set manually, e.g. 1.0
IMAGE_NAME="SEASEQ_Image_V${VERSION}"
docker run -d -p 8000:8000 SEASEQ_Image_V1.0
