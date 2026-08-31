#!/usr/bin/env bash
set -euo pipefail

if [ ! -d /runpod-volume ]; then
  echo "worker-comfyui: /runpod-volume is required (attach network volume 0vocp18ung)" >&2
  exit 1
fi

export HF_HOME="${HF_HOME:-/runpod-volume/hf-cache}"
export HUGGINGFACE_HUB_CACHE="${HUGGINGFACE_HUB_CACHE:-/runpod-volume/hf-cache}"

mkdir -p /runpod-volume/models/diffusion_models \
         /runpod-volume/models/text_encoders \
         /runpod-volume/models/vae \
         /runpod-volume/models/loras \
         "$HF_HOME"

echo "worker-comfyui: network volume detected at /runpod-volume"
python3 /opt/download_models.py

exec /start.sh
