#!/usr/bin/env bash
set -euo pipefail

if [ -d /runpod-volume ]; then
  export HF_HOME="${HF_HOME:-/runpod-volume/hf-cache}"
  export HUGGINGFACE_HUB_CACHE="${HUGGINGFACE_HUB_CACHE:-/runpod-volume/hf-cache}"
  mkdir -p /runpod-volume/models/diffusion_models \
           /runpod-volume/models/text_encoders \
           "$HF_HOME"
  echo "worker-comfyui: network volume detected at /runpod-volume"
fi

echo "worker-comfyui: ensuring large MiniMax-H3 weights are present"
python3 /opt/download_models.py

exec /start.sh
