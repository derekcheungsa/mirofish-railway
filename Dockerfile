FROM python:3.11

# Install Node.js 18
RUN apt-get update && apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
COPY --from=ghcr.io/astral-sh/uv:0.9.26 /bin/uv /bin/uv

WORKDIR /app

# Copy dependency files for install
COPY package.json package-lock.json* ./
COPY frontend/package*.json ./frontend/
COPY backend/pyproject.toml ./backend/

# uv.lock is optional - create placeholder if missing
RUN test -f backend/uv.lock || touch backend/uv.lock

# Install dependencies
RUN npm ci \
    && npm run setup \
    && uv sync --frozen --directory backend 2>/dev/null || uv sync --directory backend

# Copy source
COPY . .

EXPOSE 3000 5001 8080

CMD ["bash", "scripts/start.sh"]
