#!/usr/bin/env python3
"""Download the large MiniMax-H3 weights if they are not already on disk.

RunPod GitHub Docker builds are capped at 30 minutes. The 32GB UNET alone took
19 minutes in the last build, so these files cannot be baked into the image.
They are fetched once on worker boot (or skipped when a network volume already
has them under /runpod-volume/models).
"""

from __future__ import annotations

import os
import shutil
import sys

from huggingface_hub import hf_hub_download

HF_TOKEN = os.environ.get("HF_TOKEN") or os.environ.get("HUGGING_FACE_HUB_TOKEN")

MODELS = [
    {
        "repo_id": "Gluttony10/MiniMax-H3-INT8-CONVROT",
        "filename": "MiniMax-H3-FL2VA-int8_convrot.safetensors",
        "dest": "/comfyui/models/diffusion_models/MiniMax-H3-FL2VA-int8-convrot.safetensors",
    },
    {
        "repo_id": "Comfy-Org/MiniMax-H3",
        "filename": "text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors",
        "dest": "/comfyui/models/text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors",
    },
]


def already_present(dest: str) -> bool:
    volume = dest.replace("/comfyui/models/", "/runpod-volume/models/", 1)
    return os.path.isfile(dest) or os.path.isfile(volume)


def download(model: dict) -> None:
    dest = model["dest"]
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    print(f"worker-comfyui: downloading {model['filename']} -> {dest}", flush=True)
    cached = hf_hub_download(
        repo_id=model["repo_id"],
        filename=model["filename"],
        token=HF_TOKEN,
    )
    if os.path.abspath(cached) != os.path.abspath(dest):
        shutil.copy2(cached, dest)
    print(f"worker-comfyui: ready {dest}", flush=True)


def main() -> int:
    for model in MODELS:
        if already_present(model["dest"]):
            print(f"worker-comfyui: skip existing {model['dest']}", flush=True)
            continue
        try:
            download(model)
        except Exception as exc:
            print(f"worker-comfyui: failed to download {model['filename']}: {exc}", file=sys.stderr, flush=True)
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
