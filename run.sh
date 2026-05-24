#!/usr/bin/env sh
# Start Audiobook Studio (Linux / macOS)
cd "$(dirname "$0")"
docker compose up --build
