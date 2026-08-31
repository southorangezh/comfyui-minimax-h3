#!/usr/bin/env python3
"""Optional re-seed helper. The Docker image does not run this.

Weights are already on volume 0vocp18ung at /runpod-volume/models (Pod: /workspace/models).
The worker only verifies those files at boot.
"""

from __future__ import annotations

import os
import shutil
import sys

from huggingface_hub import hf_hub_download

HF_TOKEN = os.environ.get("HF_TOKEN") or os.environ.get("HUGGING_FACE_HUB_TOKEN")
VOLUME_ROOT = "/runpod-volume"
VOLUME_MODELS = f"{VOLUME_ROOT}/models"
HF_CACHE = f"{VOLUME_ROOT}/hf-cache"

# dest name is what api-workflow.json loads.
MODELS = [
    {
        "repo_id": "Comfy-Org/MiniMax-H3",
        "filename": "diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors",
        "relpath": "diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors",
    },
    {
        "repo_id": "Gluttony10/MiniMax-H3-INT8-CONVROT",
        "filename": "MiniMax-H3-FL2VA-int8_convrot.safetensors",
        "relpath": "diffusion_models/MiniMax-H3-FL2VA-int8-convrot.safetensors",
    },
    {
        "repo_id": "Comfy-Org/MiniMax-H3",
        "filename": "text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors",
        "relpath": "text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors",
    },
    {
        "repo_id": "Comfy-Org/MiniMax-H3",
        "filename": "vae/minimax_h3_video_vae_fp16.safetensors",
        "relpath": "vae/minimax_h3_video_vae_fp16.safetensors",
    },
    {
        "repo_id": "Comfy-Org/MiniMax-H3",
        "filename": "vae/minimax_h3_audio_vae_fp32.safetensors",
        "relpath": "vae/minimax_h3_audio_vae_fp32.safetensors",
    },
    {
        "repo_id": "lightx2v/Minimax-h3-Turbo",
        "filename": "minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors",
        "relpath": "loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors",
    },
    {
        "repo_id": "orangesouth/MinimaxH3CinematicRealism",
        "filename": "Minimax H3真实电影质感V0.1.safetensors",
        "relpath": "loras/电影镜头_000019000.safetensors",
    },
]


def dest_path(relpath: str) -> str:
    return os.path.join(VOLUME_MODELS, relpath)


def download(model: dict) -> None:
    dest = dest_path(model["relpath"])
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    print(f"worker-comfyui: downloading {model['filename']} -> {dest}", flush=True)
    cached = hf_hub_download(
        repo_id=model["repo_id"],
        filename=model["filename"],
        token=HF_TOKEN,
        cache_dir=os.environ.get("HUGGINGFACE_HUB_CACHE", HF_CACHE),
    )
    if os.path.abspath(cached) != os.path.abspath(dest):
        shutil.copy2(cached, dest)
    print(f"worker-comfyui: ready {dest}", flush=True)


def main() -> int:
    if not os.path.isdir(VOLUME_ROOT):
        print(
            "worker-comfyui: /runpod-volume is required. Attach network volume 0vocp18ung.",
            file=sys.stderr,
            flush=True,
        )
        return 1

    os.makedirs(HF_CACHE, exist_ok=True)
    os.environ.setdefault("HF_HOME", HF_CACHE)
    os.environ.setdefault("HUGGINGFACE_HUB_CACHE", HF_CACHE)

    print(f"worker-comfyui: model root is {VOLUME_MODELS}", flush=True)
    for model in MODELS:
        dest = dest_path(model["relpath"])
        if os.path.isfile(dest):
            print(f"worker-comfyui: skip existing {dest}", flush=True)
            continue
        try:
            download(model)
        except Exception as exc:
            print(
                f"worker-comfyui: failed to download {model['filename']}: {exc}",
                file=sys.stderr,
                flush=True,
            )
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
