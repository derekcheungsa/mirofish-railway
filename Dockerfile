FROM python:3.11

# Install Node.js 22
RUN apt-get update && apt-get install -y --no-install-recommends curl git \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install uv

WORKDIR /app

# Clone MiroFish
RUN git clone --depth 1 --branch main https://github.com/666ghj/MiroFish.git .

# Overlay our files
COPY package.json ./package.json
COPY src/ ./src/
COPY scripts/ ./scripts/
COPY frontend/vite.config.js ./frontend/vite.config.js

# Ensure placeholder files exist for MiroFish
RUN test -f backend/uv.lock || touch backend/uv.lock

# Install deps and build frontend into static files
RUN cd /app && npm install
RUN cd /app/frontend && npm install && npm run build
RUN cd /app/backend && uv sync --frozen 2>/dev/null || uv sync

EXPOSE 8080

CMD ["bash", "scripts/start.sh"]
