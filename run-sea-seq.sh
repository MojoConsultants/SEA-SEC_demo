#!/bin/bash

# -----------------------------
# SEA-SEQ Flexible Runner
# -----------------------------
# Usage:
#   ./run-sea-seq.sh <suite.yaml> [env.json] [openapi.json]
#
# Example:
#   ./run-sea-seq.sh tests/examples/jsonplaceholder/suite.yaml \
#       tests/examples/jsonplaceholder/env.json \
#       tests/examples/jsonplaceholder/openapi.json
#
# Reports will be generated in ./reports/
# -----------------------------
# Step one Kicking off the image build and run
# -----------------------------

# Defaults (example files)
SUITE_FILE=${1:-tests/examples/jsonplaceholder/suite.yaml}
ENV_FILE=${2:-tests/examples/jsonplaceholder/env.json}
OPENAPI_FILE=${3:-tests/examples/jsonplaceholder/openapi.json}

# Target site (can override with env var)
TARGET_SITE_URL_DEFAULT="https://mlbam-park.b12sites.com/"
TARGET_SITE_URL="${TARGET_SITE_URL:-$TARGET_SITE_URL_DEFAULT}"

# Image and container naming
IMAGE_NAME="seaseq_runner"
CONTAINER_NAME="seaseq_runner"

# Reports directory on host
REPORTS_DIR="$(pwd)/reports"
mkdir -p "$REPORTS_DIR"

echo "🔧 Building Docker image: $IMAGE_NAME"
docker build -t $IMAGE_NAME .

echo "🚀 Running SEA-SEQ with suite: $SUITE_FILE"
docker run --rm -it \
  -e TARGET_SITE_URL="$TARGET_SITE_URL" \
  -v "$REPORTS_DIR:/app/reports" \
  -v "$(pwd):/app" \
  --name $CONTAINER_NAME \
  $IMAGE_NAME \
  ./seaseq \
    --spec "$SUITE_FILE" \
    --env "$ENV_FILE" \
    --openapi "$OPENAPI_FILE" \
    --out reports -v --parallel 4



# Step 3: Notify user of completion and report location
echo "🎯 SEA-SEQ tests completed!"
echo "Congratulations! Your SEA-SEQ tests have finished running."
echo "You can find the generated reports in the 'reports' directory."
echo "✅ Reports generated in ./reports/"
echo "🔗 Target Site URL: $TARGET_SITE_URL"
echo "📂 Reports Directory: $REPORTS_DIR"
echo "🎉 SEA-SEQ testing completed!"