FROM python:3.11

# Install Node.js 18 + git + pip (for uv)
RUN apt-get update && apt-get install -y curl git \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv via pip
RUN pip install uv

# Clone MiroFish into /app
WORKDIR /app
RUN git clone --depth 1 --branch main https://github.com/666ghj/MiroFish.git .

# Copy our Express wrapper on top of MiroFish (overwrites root files only)
COPY package.json ./package.json
COPY src/ ./src/
COPY scripts/ ./scripts/

# Ensure MiroFish subdirectory files are intact
RUN test -f backend/uv.lock || touch backend/uv.lock \
    && test -f frontend/package-lock.json || true

# Install all dependencies (MiroFish + our Express wrapper)
RUN npm ci \
    && npm run setup \
    && uv sync --frozen --directory backend 2>/dev/null || uv sync --directory backend

EXPOSE 3000 5001 8080

CMD ["bash", "scripts/start.sh"]
