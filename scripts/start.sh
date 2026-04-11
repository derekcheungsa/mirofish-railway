#!/bin/bash
# MiroFish + Express Wrapper Startup Script

set -e

echo "[startup] MiroFish Railway Template starting..."

# Patch Vite config to allow Railway's public domain
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    echo "[startup] Patching Vite allowedHosts for $RAILWAY_PUBLIC_DOMAIN..."
    sed -i "s/| undefined/| '$RAILWAY_PUBLIC_DOMAIN'/" /app/frontend/vite.config.js 2>/dev/null || true
fi

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
