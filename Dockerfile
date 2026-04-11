FROM python:3.11

# Install Node.js 22 (one-time apt layer — Railway caches this)
RUN apt-get update && apt-get install -y --no-install-recommends curl git \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

WORKDIR /app

# Step 1: Clone MiroFish FIRST (can't clone into non-empty dir)
RUN git clone --depth 1 --branch main https://github.com/666ghj/MiroFish.git .

# Step 2: Overlay our Express wrapper files on top of MiroFish
COPY package.json ./package.json
COPY src/ ./src/
COPY scripts/ ./scripts/

# Step 3: Ensure placeholder files exist for MiroFish
RUN test -f backend/uv.lock || touch backend/uv.lock

# Step 4: npm install — first build populates, subsequent builds use Docker cache
RUN cd /app && npm install
RUN cd /app/frontend && npm install
RUN cd /app/backend && uv sync --frozen 2>/dev/null || uv sync

# Step 5: Replace Vite config with patched version (allows Railway host)
RUN cat > /app/frontend/vite.config.js << 'VITEEOF'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
      '@locales': path.resolve(__dirname, '../locales')
    }
  },
  server: {
    port: 3000,
    open: true,
    allowedHosts: ['all'],
    proxy: {
      '/api': {
        target: 'http://localhost:5001',
        changeOrigin: true,
        secure: false
      }
    }
  }
})
VITEEOF

EXPOSE 3000 5001 8080

CMD ["bash", "scripts/start.sh"]
