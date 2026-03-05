# Ollama + Open WebUI Pod Template

A RunPod pod template bundling Ollama (LLM inference engine) with Open WebUI (chat frontend) in a single optimized Docker image.

---

## Stack

- **Base**: `ollama/ollama:latest` (NVIDIA CUDA-ready)
- **Frontend**: Open WebUI 0.8.8+ (Python pip install)
- **Python**: 3.11
- **Default Model**: HammerAI/midnight-miqu-70b-v1.5 (42 GB, auto-pulled on first boot)

---

## Designed For

**Minimum specs:**
- RTX PRO 6000 (96 GB VRAM) or equivalent
- 188 GB system RAM
- 16 vCPU
- 110 GB volume storage (for model weights)

The 42 GB model fits comfortably with room for KV cache and concurrent requests.

---

## Quickstart

### Deploy on RunPod

1. Use this template on [runpod.io/console/user/templates](https://www.runpod.io/console/user/templates)
2. Set these values:
   - **Container Image**: `ghcr.io/bbybrx/runpod-template-1:latest`
   - **Container Disk**: 15 GB
   - **Volume Disk**: 110 GB
   - **HTTP Port**: 8080 (Open WebUI)
   - **TCP Port**: 11434 (Ollama API)

3. Environment variables (optional — defaults shown):
   - `DEFAULT_MODEL` = `HammerAI/midnight-miqu-70b-v1.5:latest`
   - `OLLAMA_FLASH_ATTENTION` = `1`
   - `OLLAMA_NUM_PARALLEL` = `4`
   - `ENABLE_SIGNUP` = `true`

4. Deploy and wait for startup (~2 min).

---

## On First Boot

1. Ollama server starts immediately
2. Open WebUI launches on port 8080
3. **Model pulls in background** — 42 GB download (~10–30 min depending on connection)
   - Monitor progress: tail the log at `/workspace/model-pull.log`
   - You can start using Open WebUI while the download happens
   - Once complete, create an account and select the model from the dropdown

**On subsequent boots**: Model is already on the volume — everything starts in seconds.

---

## Services

| Service | Port | URL |
|---------|------|-----|
| **Open WebUI** | 8080 | `https://{POD_ID}-8080.proxy.runpod.net` |
| **Ollama API** | 11434 | `https://{POD_ID}-11434.proxy.runpod.net` |

---

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `DEFAULT_MODEL` | `HammerAI/midnight-miqu-70b-v1.5:latest` | Model to auto-pull on first boot |
| `OLLAMA_FLASH_ATTENTION` | `1` | Enable flash attention (faster, less VRAM) |
| `OLLAMA_NUM_PARALLEL` | `4` | Concurrent request handling |
| `ENABLE_SIGNUP` | `true` | Allow first-time user signup (first user = admin) |
| `VOLUME_DIR` | `/workspace` | Volume mount path (don't change) |

---

## Volume Layout

```
/workspace/
├── ollama/
│   └── models/              # Model weights (~42 GB)
│       └── midnight-miqu...
├── open-webui/              # WebUI data, chats, uploads
│   ├── .secret_key
│   └── data.db
└── model-pull.log           # Pull progress on first boot
```

---

## Notes

- The Docker image is ~6–8 GB (CPU-only PyTorch to avoid redundant CUDA libraries — Ollama handles GPU inference)
- Model weights are stored on the volume, not in the image
- Open WebUI requires signup; first account becomes admin
- API key generation happens in the Open WebUI settings
