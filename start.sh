#!/bin/bash

echo "========================================="
echo "  Ollama + Open WebUI  |  RunPod"
echo "========================================="

# ---------------------------------------------------------------------------
# Volume setup – persist models & WebUI data across pod restarts
# ---------------------------------------------------------------------------
VOLUME_DIR="${VOLUME_DIR:-/workspace}"
OLLAMA_DIR="$VOLUME_DIR/ollama"
WEBUI_DIR="$VOLUME_DIR/open-webui"

echo "[init] Creating volume directories..."
mkdir -p "$OLLAMA_DIR/models" "$WEBUI_DIR"
echo "[init] Done."

# ---------------------------------------------------------------------------
# Verify required binaries are available
# ---------------------------------------------------------------------------
echo "[init] Checking required binaries..."
for bin in ollama open-webui openssl curl; do
    if ! command -v "$bin" > /dev/null 2>&1; then
        echo "[ERROR] Required binary not found: $bin"
        echo "[ERROR] PATH is: $PATH"
        exit 1
    fi
    echo "        $bin -> $(command -v $bin)"
done

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
echo "      PID: $OLLAMA_PID"

echo "      Waiting for Ollama to become ready..."
OLLAMA_READY=0
for i in $(seq 1 60); do
    if curl -s http://localhost:11434/api/version > /dev/null 2>&1; then
        OLLAMA_READY=1
        echo "      Ollama is ready (${i}s)."
        break
    fi
    sleep 1
done

if [ "$OLLAMA_READY" -eq 0 ]; then
    echo "[ERROR] Ollama failed to become ready within 60 seconds."
    exit 1
fi

# ---------------------------------------------------------------------------
# 2) Pull default model (background, skipped if already present)
# ---------------------------------------------------------------------------
DEFAULT_MODEL="${DEFAULT_MODEL:-HammerAI/midnight-miqu-70b-v1.5:latest}"
echo "[2/3] Checking model: $DEFAULT_MODEL"

if ollama list 2>/dev/null | grep -q "midnight-miqu"; then
    echo "      Model already on volume."
else
    echo "      Model not found. Pulling in background (~42 GB)..."
    echo "      Monitor: tail -f $VOLUME_DIR/model-pull.log"
    nohup sh -c "ollama pull \"$DEFAULT_MODEL\" 2>&1 | tee \"$VOLUME_DIR/model-pull.log\" && echo 'PULL_COMPLETE' >> \"$VOLUME_DIR/model-pull.log\"" &
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
    export WEBUI_SECRET_KEY
    WEBUI_SECRET_KEY=$(cat "$SECRET_KEY_FILE")
    echo "      Loaded existing secret key."
else
    export WEBUI_SECRET_KEY
    WEBUI_SECRET_KEY=$(openssl rand -hex 32)
    echo "$WEBUI_SECRET_KEY" > "$SECRET_KEY_FILE"
    chmod 600 "$SECRET_KEY_FILE"
    echo "      Generated new secret key."
fi

open-webui serve --host 0.0.0.0 --port 8080 &
WEBUI_PID=$!
echo "      PID: $WEBUI_PID"

# ---------------------------------------------------------------------------
# Ready
# ---------------------------------------------------------------------------
echo ""
echo "========================================="
echo "  Services running"
echo "  WebUI : https://${RUNPOD_POD_ID}-8080.proxy.runpod.net"
echo "  API   : https://${RUNPOD_POD_ID}-11434.proxy.runpod.net"
echo "========================================="
echo ""

# ---------------------------------------------------------------------------
# Signal handling – graceful shutdown
# ---------------------------------------------------------------------------
cleanup() {
    echo "Shutting down..."
    kill "$WEBUI_PID" 2>/dev/null
    kill "$OLLAMA_PID" 2>/dev/null
    [ -n "${PULL_PID:-}" ] && kill "$PULL_PID" 2>/dev/null
    wait
    exit 0
}
trap cleanup SIGTERM SIGINT

# Keep the container alive — if a service dies, log it but don't exit
while true; do
    if ! kill -0 "$OLLAMA_PID" 2>/dev/null; then
        echo "[WARN] Ollama process died. Restarting..."
        ollama serve &
        OLLAMA_PID=$!
    fi
    if ! kill -0 "$WEBUI_PID" 2>/dev/null; then
        echo "[WARN] Open WebUI process died. Restarting..."
        open-webui serve --host 0.0.0.0 --port 8080 &
        WEBUI_PID=$!
    fi
    sleep 10
done
