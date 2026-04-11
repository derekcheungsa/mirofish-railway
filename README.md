# MiroFish Railway Template

Deploy [MiroFish](https://github.com/666ghj/MiroFish) — multi-agent AI prediction engine — on Railway with one click.

## What You Get

- **MiroFish** — Simulate thousands of AI agents that predict future outcomes
- **OpenRouter Integration** — Power your agents with 300+ models through a single API
- **Setup Wizard** — Configure API keys via web UI at `/setup`
- **Persistent Storage** — State survives redeploys via Railway Volume

## How to Deploy

### One-Click Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template/github?template=MiroFish-Railway-Template)

1. **Create the template** from this GitHub repo
2. **Add a Volume** mounted at `/data`
3. **Set environment variables** (see below)
4. **Enable Public Networking** — Railway will assign a domain
5. **Deploy**

That's it! After deployment, visit `https://<your-app>.up.railway.app/setup` to configure.

---

## Required Environment Variables

Set these in Railway Variables:

| Variable | Description | Where to get it |
|---|---|---|
| `SETUP_PASSWORD` | Password for the setup wizard | *Create your own* |
| `LLM_API_KEY` | Your LLM API key | [openrouter.ai/keys](https://openrouter.ai/keys) |
| `LLM_BASE_URL` | OpenRouter endpoint | `https://openrouter.ai/api/v1` |
| `LLM_MODEL_NAME` | Model to use | e.g., `openai/gpt-4o-mini` |

### Optional Variables

| Variable | Default | Description |
|---|---|---|
| `ZEP_API_KEY` | — | [Zep Cloud](https://console.zep.cloud/) for agent memory |
| `SECRET_KEY` | `mirofish-dev-secret` | Flask secret key |

---

## The Setup Wizard

After deploying, visit `/setup` on your app to configure MiroFish without running commands.

The wizard lets you:
- Enter your OpenRouter API key
- Select from popular models
- Optionally add Zep Cloud for agent memory

---

## Architecture

```
Railway → Express Wrapper (port 8080)
                ↓
         /setup → Setup Wizard (protected)
                ↓
         /api → MiroFish Backend (port 5001)
                ↓
         /     → MiroFish Frontend (port 3000)
```

The Express wrapper:
- Proxies API requests to the backend (port 5001)
- Proxies frontend requests to the frontend (port 3000)
- Serves the setup wizard at `/setup`
- Handles WebSocket upgrades for both services

---

## MiroFish + OpenRouter

This template is designed to highlight **OpenRouter** as the LLM provider:

- **300+ models** from 60+ providers — GPT-4o, Claude, Gemini, DeepSeek, Mistral, Llama, and more
- **Single API key** — swap models without changing code
- **Pay-as-you-go** — no subscriptions, no vendor lock-in
- **Automatic fallback** — if one provider goes down, OpenRouter routes to another

### Recommended Models for MiroFish

| Model | Best For | Context Window |
|---|---|---|
| `openai/gpt-4o-mini` | Fast, cheap simulations | 128k |
| `anthropic/claude-3-5-sonnet-latest` | High-quality reasoning | 200k |
| `google/gemini-2.5-pro-preview` | Long context analysis | 1M |
| `deepseek/deepseek-chat-v3-0324` | Budget-friendly | 131k |
| `meta-llama/llama-3.3-70b-instruct` | Open weights | 131k |

---

## Docker (Local Development)

```bash
# Build
docker build -t mirofish .

# Run
docker run --rm -p 8080:8080 \
  -e SETUP_PASSWORD=test \
  -e LLM_API_KEY=your_key \
  -e LLM_BASE_URL=https://openrouter.ai/api/v1 \
  -e LLM_MODEL_NAME=openai/gpt-4o-mini \
  -v mirofish-data:/data \
  mirofish

# Open http://localhost:8080/setup
# Password: test
```

---

## MiroFish Resources

- [GitHub](https://github.com/666ghj/MiroFish)
- [Documentation](https://github.com/666ghj/MiroFish#readme)
- [OpenRouter](https://openrouter.ai/)
- [Zep Cloud](https://console.zep.cloud/)
