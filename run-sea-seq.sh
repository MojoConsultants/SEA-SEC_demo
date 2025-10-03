#!/bin/bash
set -e

# Detect docker compose command
if command -v docker-compose &>/dev/null; then
  COMPOSE="docker-compose"
else
  COMPOSE="docker compose"
fi

CLI_CONTAINER="seaseq-cli"
API_CONTAINER="seaseq-api"

case "$1" in
  cli)
    shift
    if [ $# -eq 0 ]; then
      echo "🚀 Running SEA-SEQ CLI with default JSONPlaceholder suite..."
      $COMPOSE run --rm $CLI_CONTAINER \
        --spec tests/examples/jsonplaceholder/suite.yaml \
        --env tests/examples/jsonplaceholder/env.json \
        --openapi tests/examples/jsonplaceholder/openapi.json \
        --out reports -v --parallel 4
    else
      echo "🚀 Running SEA-SEQ CLI with custom args: $@"
      $COMPOSE run --rm $CLI_CONTAINER "$@"
    fi
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
    echo "Usage: $0 {cli|api|both|down} [args...]"
    ;;
esac
