#!/usr/bin/env python3
"""Download large MiniMax-H3 weights onto the network volume when present.

RunPod GitHub Docker builds time out at 30 minutes, so these files are not
baked into the image. Prefer /runpod-volume so a 40GB container disk and
min-workers=0 cold starts do not re-download ~50GB every time.
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

MODELS = [
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
]


def models_root() -> str:
    if os.path.isdir(VOLUME_ROOT):
        os.makedirs(HF_CACHE, exist_ok=True)
        os.environ.setdefault("HF_HOME", HF_CACHE)
        os.environ.setdefault("HUGGINGFACE_HUB_CACHE", HF_CACHE)
        return VOLUME_MODELS
    return "/comfyui/models"


def dest_paths(relpath: str) -> list[str]:
    return [
        os.path.join(VOLUME_MODELS, relpath),
        os.path.join("/comfyui/models", relpath),
    ]


def already_present(relpath: str) -> str | None:
    for path in dest_paths(relpath):
        if os.path.isfile(path):
            return path
    return None


def download(model: dict, root: str) -> None:
    dest = os.path.join(root, model["relpath"])
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    print(f"worker-comfyui: downloading {model['filename']} -> {dest}", flush=True)
    cached = hf_hub_download(
        repo_id=model["repo_id"],
        filename=model["filename"],
        token=HF_TOKEN,
        cache_dir=os.environ.get("HUGGINGFACE_HUB_CACHE"),
    )
    if os.path.abspath(cached) != os.path.abspath(dest):
        shutil.copy2(cached, dest)
    print(f"worker-comfyui: ready {dest}", flush=True)


def main() -> int:
    root = models_root()
    print(f"worker-comfyui: model root is {root}", flush=True)
    for model in MODELS:
        existing = already_present(model["relpath"])
        if existing:
            print(f"worker-comfyui: skip existing {existing}", flush=True)
            continue
        try:
            download(model, root)
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
