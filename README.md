# MiniMax+H3_真实电影质感
ComfyUI workflow Dockerized via [comfyui-wizard](https://comfy.getrunpod.io).
Submission: https://comfy.getrunpod.io/dashboard/submissions/kd78hh028sa8f178gh0mv2t0598dhws9

The Docker image contains **custom nodes only**. Every model is loaded from the
RunPod network volume mounted at `/runpod-volume`.

The worker base image ships ComfyUI 0.29.x. This repo upgrades it to **ComfyUI
v0.34.0** at build time so native MiniMax-H3 modules exist (`comfy.ldm.minimax`,
`MiniMaxH3ImageToVideo`, `comfy.model_prefetch`), then reinstalls **PyTorch
2.10.0+cu126** so it matches US-IL-1 ADA GPUs (driver CUDA 12.6). Rebuild the
image after pulling these changes; an old worker will keep failing on
`missing_node_type` or `NVIDIA driver ... too old`.

## Network volume layout

Attach volume `0vocp18ung` (`crowded_rose_wolverine`) in US-IL-1. Paths inside
the worker:

```text
/runpod-volume/models/
  diffusion_models/MiniMax-H3-FL2VA-int8-convrot.safetensors
  text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors
  vae/minimax_h3_video_vae_fp16.safetensors
  vae/minimax_h3_audio_vae_fp32.safetensors
  loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors
  loras/电影镜头_000019000.safetensors
```

S3 (same files):

```text
s3://0vocp18ung/models/diffusion_models/...
s3://0vocp18ung/models/text_encoders/...
s3://0vocp18ung/models/vae/...
s3://0vocp18ung/models/loras/...
```

If a file is missing, the worker downloads it onto the volume on first boot.
Pre-upload via S3 to skip that. Hugging Face cache also lives on the volume
(` /runpod-volume/hf-cache`).

## Deploy on Runpod

1. Connect this repository at https://runpod.io/console/serverless
2. Deploy from GitHub, repo `southorangezh/comfyui-minimax-h3`, branch `main`
3. Queue endpoint, attach volume `0vocp18ung`, region US-IL-1
4. Container disk can stay small (20–40GB). Idle timeout ≥ 300s. Job timeout ≥ 30 min
5. Send `api-workflow.json` to `/run` or `/runsync`

The yellow `runpod.serverless.start() handler not found` banner is a GitHub
search-index false alarm. `handler.py` is on `main`.

## Files

- `Dockerfile` — custom nodes only; no model weights
- `download_models.py` — fills `/runpod-volume/models` if files are missing
- `extra_model_paths.yaml` — makes ComfyUI read the network volume
- `handler.py` / `rp_handler.py` — RunPod queue handler
- `api-workflow.json` — ComfyUI `/prompt` payload
- `workflow.json` — original ComfyUI graph
