#!/usr/bin/env bash
set -euo pipefail

VOLUME_ROOT=/runpod-volume
MODELS="${VOLUME_ROOT}/models"

if [ ! -d "$VOLUME_ROOT" ]; then
  echo "worker-comfyui: ${VOLUME_ROOT} is required (attach network volume 0vocp18ung)" >&2
  exit 1
fi

required=(
  "${MODELS}/diffusion_models/MiniMax-H3-FL2VA-int8-convrot.safetensors"
  "${MODELS}/text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors"
  "${MODELS}/vae/minimax_h3_video_vae_fp16.safetensors"
  "${MODELS}/vae/minimax_h3_audio_vae_fp32.safetensors"
  "${MODELS}/loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors"
  "${MODELS}/loras/电影镜头_000019000.safetensors"
)

echo "worker-comfyui: network volume detected at ${VOLUME_ROOT}"

# First image that bakes the pruned UNET copies it onto the volume so later
# Dockerfiles can drop the download RUN.
PRUNED_NAME="minimax_h3_fl2va_pruned_int8_convrot.safetensors"
IMAGE_PRUNED="/comfyui/models/diffusion_models/${PRUNED_NAME}"
VOLUME_PRUNED="${MODELS}/diffusion_models/${PRUNED_NAME}"
if [ -f "${IMAGE_PRUNED}" ]; then
  echo "worker-comfyui: ok $(stat -c '%s %n' "${IMAGE_PRUNED}")"
  if [ ! -f "${VOLUME_PRUNED}" ]; then
    echo "worker-comfyui: seeding volume from image -> ${VOLUME_PRUNED}"
    mkdir -p "$(dirname "${VOLUME_PRUNED}")"
    cp -f "${IMAGE_PRUNED}" "${VOLUME_PRUNED}"
    echo "worker-comfyui: seeded $(stat -c '%s %n' "${VOLUME_PRUNED}")"
  fi
fi

missing=0
for path in "${required[@]}"; do
  if [ -f "$path" ]; then
    echo "worker-comfyui: ok $(stat -c '%s %n' "$path")"
  else
    echo "worker-comfyui: missing ${path}" >&2
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  echo "worker-comfyui: pre-seeded weights missing on volume 0vocp18ung; refusing to download at worker boot" >&2
  exit 1
fi

exec /start.sh
