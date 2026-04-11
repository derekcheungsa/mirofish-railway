#!/bin/bash
# MiroFish + Express Wrapper Startup Script (Production Mode)

set -e

echo "[startup] MiroFish Railway Template starting..."

# Start MiroFish backend (Python/Flask on 5001) in background
cd /app
echo "[startup] Starting MiroFish backend..."
cd backend && uv run python run.py &
BACKEND_PID=$!
cd /app
echo "[startup] Backend started (PID $BACKEND_PID)"

# Give backend time to start
sleep 3

# Start Express wrapper — serves built frontend static files + /setup wizard
echo "[startup] Starting Express wrapper on port $PORT..."
exec node src/server.js
