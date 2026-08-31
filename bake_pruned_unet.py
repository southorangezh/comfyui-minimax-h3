#!/usr/bin/env python3
"""One-shot bake of the pruned MiniMax-H3 UNET into the image.

Delete this file together with the Dockerfile ONE-SHOT RUN after the first
worker has copied the weights onto volume 0vocp18ung.
"""

from __future__ import annotations

import os
import shutil

from huggingface_hub import hf_hub_download

REPO_ID = "Comfy-Org/MiniMax-H3"
FILENAME = "diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors"
DEST = "/comfyui/models/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors"
MIN_BYTES = 20_000_000_000


def main() -> None:
    token = os.environ.get("HF_TOKEN") or None
    src = hf_hub_download(repo_id=REPO_ID, filename=FILENAME, token=token)
    os.makedirs(os.path.dirname(DEST), exist_ok=True)
    shutil.copy2(src, DEST)
    size = os.path.getsize(DEST)
    print(f"baked {size} {DEST}", flush=True)
    if size < MIN_BYTES:
        raise SystemExit(f"pruned UNET too small: {size} bytes")


if __name__ == "__main__":
    main()
