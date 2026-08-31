"""RunPod GitHub integration looks for this file in the repository.

The container does NOT run this file. The `runpod/worker-comfyui` base image
already ships `/handler.py` and starts it via `/start.sh` after ComfyUI is up:

    python -u /handler.py
    → runpod.serverless.start({"handler": handler})

Keep this file in the repo so RunPod can detect `runpod.serverless.start()`.
Do not COPY it into the image, or it will overwrite the ComfyUI worker.
"""

import runpod


def handler(job):
    """Detected by RunPod. Real ComfyUI jobs are handled by the base image."""
    return job.get("input", {})


if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})
