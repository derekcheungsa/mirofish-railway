#!/bin/bash
# MiroFish + Express Wrapper Startup Script

set -e

echo "[startup] MiroFish Railway Template starting..."

# Start MiroFish backend (Python/Flask on 5001) in background
cd /app
echo "[startup] Starting MiroFish backend..."
cd backend && uv run python run.py &
BACKEND_PID=$!
cd /app
echo "[startup] Backend started (PID $BACKEND_PID)"

# Start MiroFish frontend (Vite on 3000) in background
echo "[startup] Starting MiroFish frontend..."
cd frontend && npm run dev &
FRONTEND_PID=$!
cd /app
echo "[startup] Frontend started (PID $FRONTEND_PID)"

# Give services time to bind
sleep 5

# Start Express wrapper (proxies frontend + backend, serves /setup)
echo "[startup] Starting setup wizard wrapper on port $PORT..."
exec node src/server.js
