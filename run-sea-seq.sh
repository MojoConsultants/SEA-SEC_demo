#!/bin/bash
set -e

# Detect docker compose command (new vs old)
if command -v docker-compose &>/dev/null; then
  COMPOSE="docker-compose"
else
  COMPOSE="docker compose"
fi

CLI_CONTAINER="seaseq-cli"
API_CONTAINER="seaseq-api"

case "$1" in
  cli)
    echo "🚀 Running SEA-SEQ CLI..."
    $COMPOSE run --rm $CLI_CONTAINER
    ;;
  api)
    echo "🚀 Running SEA-SEQ API Service on http://localhost:8000 ..."
    $COMPOSE up $API_CONTAINER
    ;;
  both)
    echo "🚀 Running CLI and API together..."
    $COMPOSE up
    ;;
  down)
    echo "🛑 Stopping all containers and removing volumes..."
    $COMPOSE down -v || true
    ;;
  *)
    echo "Usage: $0 {cli|api|both|down}"
    ;;
esac
