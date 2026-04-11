FROM python:3.11

# Install Node.js 22 (one-time apt layer — Railway caches this)
RUN apt-get update && apt-get install -y --no-install-recommends curl git \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

WORKDIR /app

# Step 1: Copy package files FIRST (changes rarely → Docker caches this layer)
COPY package.json ./package.json
COPY src/ ./src/
COPY scripts/ ./scripts/

# Step 2: Clone MiroFish AFTER package files (changes every deploy anyway)
RUN git clone --depth 1 --branch main https://github.com/666ghj/MiroFish.git .

# Ensure placeholder files exist for MiroFish
RUN test -f backend/uv.lock || touch backend/uv.lock

# Step 3: npm install — first build populates, subsequent builds use Docker cache
RUN cd /app && npm install
RUN cd /app/frontend && npm install
RUN cd /app/backend && uv sync --frozen 2>/dev/null || uv sync

# Step 4: Patch Vite config at BUILD TIME (not at startup)
RUN sed -i "s/open: true,/open: true,\n    allowedHosts: ['all'],/" /app/frontend/vite.config.js || true

EXPOSE 3000 5001 8080

CMD ["bash", "scripts/start.sh"]
