#!/usr/bin/env bash
set -euo pipefail

echo "worker-comfyui: ensuring large MiniMax-H3 weights are present"
python3 /opt/download_models.py

exec /start.sh
