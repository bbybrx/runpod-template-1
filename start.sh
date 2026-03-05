#!/bin/bash
set -e

echo "========================================="
echo "  Ollama + Open WebUI  |  RunPod"
echo "========================================="

# ---------------------------------------------------------------------------
# Volume setup – persist models & WebUI data across pod restarts
# ---------------------------------------------------------------------------
VOLUME_DIR="${VOLUME_DIR:-/workspace}"
OLLAMA_DIR="$VOLUME_DIR/ollama"
WEBUI_DIR="$VOLUME_DIR/open-webui"

mkdir -p "$OLLAMA_DIR/models" "$WEBUI_DIR"

# ---------------------------------------------------------------------------
# Ollama configuration
# ---------------------------------------------------------------------------
export OLLAMA_MODELS="$OLLAMA_DIR/models"
export OLLAMA_HOST="0.0.0.0:11434"
export OLLAMA_FLASH_ATTENTION="${OLLAMA_FLASH_ATTENTION:-1}"
export OLLAMA_NUM_PARALLEL="${OLLAMA_NUM_PARALLEL:-4}"
export OLLAMA_MAX_LOADED_MODELS="${OLLAMA_MAX_LOADED_MODELS:-1}"

# ---------------------------------------------------------------------------
# 1) Start Ollama
# ---------------------------------------------------------------------------
echo "[1/3] Starting Ollama server..."
ollama serve &
OLLAMA_PID=$!

for i in $(seq 1 60); do
    if curl -s http://localhost:11434/api/version > /dev/null 2>&1; then
        echo "      Ollama is ready."
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo "      ERROR: Ollama failed to start within 60 seconds."
        exit 1
    fi
    sleep 1
done

# ---------------------------------------------------------------------------
# 2) Pull default model (background, skipped if already present)
# ---------------------------------------------------------------------------
DEFAULT_MODEL="${DEFAULT_MODEL:-HammerAI/midnight-miqu-70b-v1.5:latest}"
echo "[2/3] Checking model: $DEFAULT_MODEL"

if ollama list 2>/dev/null | grep -q "midnight-miqu"; then
    echo "      Model already downloaded."
else
    echo "      Model not found on volume. Pulling in background (~42 GB)..."
    echo "      Monitor: tail -f $VOLUME_DIR/model-pull.log"
    nohup sh -c "ollama pull \"$DEFAULT_MODEL\" 2>&1 | tee \"$VOLUME_DIR/model-pull.log\"; echo 'PULL_COMPLETE' >> \"$VOLUME_DIR/model-pull.log\"" &
    PULL_PID=$!
    echo "      Pull started (PID $PULL_PID)."
fi

# ---------------------------------------------------------------------------
# 3) Start Open WebUI
# ---------------------------------------------------------------------------
echo "[3/3] Starting Open WebUI on port 8080..."

export DATA_DIR="$WEBUI_DIR"
export OLLAMA_BASE_URL="http://localhost:11434"
export ENABLE_SIGNUP="${ENABLE_SIGNUP:-true}"

# Persist the JWT secret across pod restarts
SECRET_KEY_FILE="$WEBUI_DIR/.secret_key"
if [ -f "$SECRET_KEY_FILE" ]; then
    export WEBUI_SECRET_KEY=$(cat "$SECRET_KEY_FILE")
else
    export WEBUI_SECRET_KEY=$(openssl rand -hex 32)
    echo "$WEBUI_SECRET_KEY" > "$SECRET_KEY_FILE"
    chmod 600 "$SECRET_KEY_FILE"
fi

open-webui serve --host 0.0.0.0 --port 8080 &
WEBUI_PID=$!

# ---------------------------------------------------------------------------
# Ready
# ---------------------------------------------------------------------------
echo ""
echo "========================================="
echo "  Services running"
echo "  WebUI : https://\${RUNPOD_POD_ID}-8080.proxy.runpod.net"
echo "  API   : https://\${RUNPOD_POD_ID}-11434.proxy.runpod.net"
echo "========================================="
echo ""

# ---------------------------------------------------------------------------
# Signal handling – graceful shutdown
# ---------------------------------------------------------------------------
cleanup() {
    echo "Shutting down..."
    kill "$WEBUI_PID" 2>/dev/null
    kill "$OLLAMA_PID" 2>/dev/null
    [ -n "$PULL_PID" ] && kill "$PULL_PID" 2>/dev/null
    wait
    exit 0
}
trap cleanup SIGTERM SIGINT

# Keep the container alive
wait
