#!/bin/bash
set -e

# Usage: ./reset-sea-seq.sh [cli|api|both]
TARGET=${1:-both}

echo "🛑 Stopping and cleaning up old containers..."
docker-compose down -v || true

echo "🧹 Pruning Docker system (images, cache, volumes)..."
docker system prune -af --volumes || true

echo "🔧 Building images from scratch..."
docker-compose build --no-cache

echo "🚀 Starting SEA-SEQ with target: $TARGET"
./run-sea-seq.sh $TARGET
