#!/bin/bash
# MiroFish + Express Wrapper Startup Script
# Railway starts the container with CMD from Dockerfile (npm run dev)
# This script: (1) starts MiroFish backend+frontend, (2) runs the Express wrapper

set -e

echo "[startup] MiroFish Railway Template starting..."

# Start MiroFish backend + frontend in background
cd /app
echo "[startup] Starting MiroFish backend + frontend services..."
npm run dev &
MIROFISH_PID=$!
echo "[startup] MiroFish started (PID $MIROFISH_PID)"

# Give services a moment to bind to their ports
sleep 5

# Start Express wrapper (proxies to MiroFish + serves /setup wizard)
# The wrapper is the main process that Railway talks to
echo "[startup] Starting setup wizard wrapper on port $PORT..."
exec node src/server.js

# If we get here, wrapper exited — stop MiroFish
echo "[startup] Wrapper stopped, shutting down MiroFish..."
kill $MIROFISH_PID 2>/dev/null || true
