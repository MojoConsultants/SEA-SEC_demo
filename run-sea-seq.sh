#!/bin/bash
set -e

CLI_CONTAINER="seaseq-cli"
API_CONTAINER="seaseq-api"

echo "📦 Checking Go dependencies..."
if command -v go >/dev/null 2>&1; then
  go mod tidy
else
  echo "⚠️ Go not installed locally — skipping local tidy"
fi

echo "🔧 Building Docker images..."
docker-compose build --no-cache

case "$1" in
  cli)
    echo "🚀 Running SEA-SEQ CLI..."
    docker-compose run --rm $CLI_CONTAINER
    ;;
  api)
    echo "🚀 Running SEA-SEQ API Service on http://localhost:8000 ..."
    docker-compose up $API_CONTAINER
    ;;
  both)
    echo "🚀 Running CLI and API together..."
    docker-compose up
    ;;
  down)
    echo "🛑 Stopping all containers..."
    docker-compose down -v
    ;;
  *)
    echo "Usage: $0 {cli|api|both|down}"
    ;;
esac
