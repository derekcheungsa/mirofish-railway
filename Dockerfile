FROM python:3.11

# Install Node.js 18 + git
RUN apt-get update && apt-get install -y curl git \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv via pip
RUN pip install uv

WORKDIR /app

# Clone MiroFish into /app
RUN git clone --depth 1 --branch main https://github.com/666ghj/MiroFish.git .

# Copy our Express wrapper on top of MiroFish
COPY package.json ./package.json
COPY src/ ./src/
COPY scripts/ ./scripts/

# Ensure placeholder files exist for MiroFish
RUN test -f backend/uv.lock || touch backend/uv.lock

# ==========================================================
# Install ALL deps in one place (/app/node_modules)
# Our package.json merge-strategies over MiroFish's root deps,
# but we keep MiroFish's subdir deps intact.
# ==========================================================
RUN cd /app \
    && npm install \
    && cd frontend && npm install \
    && cd ../backend && uv sync --frozen 2>/dev/null || uv sync

EXPOSE 3000 5001 8080

CMD ["bash", "scripts/start.sh"]
