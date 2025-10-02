#!/bin/bash

VERSION=$(cat version.txt)  # or set manually, e.g. 1.0
IMAGE_NAME="SEASEQ_Image_V${VERSION}"

docker run --rm --entrypoint python $IMAGE_NAME runner_cli.py scan --target demo.com
