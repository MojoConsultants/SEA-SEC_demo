#!/bin/bash
set -e

# Detect docker compose command (new vs old)
if command -v docker-compose &>/dev/null; then
  COMPOSE="docker-compose"
else
  COMPOSE="docker compose"
fi

TARGET=${1:-both}

echo "🛑 Stopping and cleaning up old containers..."
$COMPOSE down -v || true

echo "🧹 Pruning Docker system (images, cache, volumes)..."
docker system prune -af --volumes || true

echo "🔧 Building images from scratch..."
$COMPOSE build --no-cache

echo "🚀 Starting SEA-SEQ with target: $TARGET"
./run-sea-seq.sh $TARGET
