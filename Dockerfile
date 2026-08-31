# Nodes only. MiniMax-H3 weights are already on network volume 0vocp18ung.
# Pod mount /workspace/models == serverless /runpod-volume/models:
#
#   models/diffusion_models/MiniMax-H3-FL2VA-int8-convrot.safetensors
#   models/text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors
#   models/vae/minimax_h3_video_vae_fp16.safetensors
#   models/vae/minimax_h3_audio_vae_fp32.safetensors
#   models/loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors
#   models/loras/电影镜头_000019000.safetensors
#
# Do not COPY or wget those files. Attach volume 0vocp18ung in US-IL-1.
#
# worker-comfyui 5.8.x ships ComfyUI <= 0.29, which predates native MiniMax-H3
# (comfy.ldm.minimax, MiniMaxH3ImageToVideo, comfy.model_prefetch).
FROM runpod/worker-comfyui:5.8.6-base

ARG COMFYUI_VERSION=v0.34.0
RUN git -C /comfyui remote set-url origin https://github.com/Comfy-Org/ComfyUI.git \
    && git -C /comfyui fetch --depth 1 origin tag ${COMFYUI_VERSION} \
    && git -C /comfyui checkout --force FETCH_HEAD \
    && grep -vE '^(torch|torchvision|torchaudio)($|[[:space:]])' /comfyui/requirements.txt > /tmp/comfy-reqs.txt \
    && uv pip install --no-cache -r /tmp/comfy-reqs.txt \
    && uv pip install "transformers>=4.50.3,<5" "huggingface-hub<1.0"

RUN git clone https://github.com/yolain/ComfyUI-Easy-Use /comfyui/custom_nodes/ComfyUI-Easy-Use && cd /comfyui/custom_nodes/ComfyUI-Easy-Use && (git checkout 5618a748c14858a6e95a583baa28bb7c8da7976a 2>/dev/null || (git fetch origin 5618a748c14858a6e95a583baa28bb7c8da7976a --depth=1 && git checkout 5618a748c14858a6e95a583baa28bb7c8da7976a) || echo "WARN: commit 5618a748c14858a6e95a583baa28bb7c8da7976a unreachable in https://github.com/yolain/ComfyUI-Easy-Use, falling back to default branch HEAD")
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts /comfyui/custom_nodes/ComfyUI-Custom-Scripts && cd /comfyui/custom_nodes/ComfyUI-Custom-Scripts && (git checkout 609f3afaa74b2f88ef9ce8d939626065e3247469 2>/dev/null || (git fetch origin 609f3afaa74b2f88ef9ce8d939626065e3247469 --depth=1 && git checkout 609f3afaa74b2f88ef9ce8d939626065e3247469) || echo "WARN: commit 609f3afaa74b2f88ef9ce8d939626065e3247469 unreachable in https://github.com/pythongosssss/ComfyUI-Custom-Scripts, falling back to default branch HEAD")
# Fast Groups Bypasser is a frontend virtual node; keep rgthree for GUI use only.
RUN git clone --depth 1 https://github.com/rgthree/rgthree-comfy /comfyui/custom_nodes/rgthree-comfy
RUN git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes /comfyui/custom_nodes/ComfyUI-KJNodes \
    && uv pip install --no-cache -r /comfyui/custom_nodes/ComfyUI-KJNodes/requirements.txt
RUN comfy node install --exit-on-fail vsaan212-workflow-utilities
RUN git clone https://github.com/T8mars/comfyui-minimax-h3-blockcache-T8 /comfyui/custom_nodes/comfyui-minimax-h3-blockcache-T8
RUN git clone https://github.com/wjc573/ComfyUI-H3LatentUpscale-jingchen573 /comfyui/custom_nodes/ComfyUI-H3LatentUpscale-jingchen573
RUN git clone https://github.com/LBH-123-AI/Comfyui_Minimax_h3_latent_Upscaler /comfyui/custom_nodes/Comfyui_Minimax_h3_latent_Upscaler

RUN for r in /comfyui/custom_nodes/*/requirements.txt; do \
      [ -f "$r" ] && uv pip install --no-cache -r "$r" || true; \
    done

RUN mkdir -p /opt && cp /handler.py /opt/worker-comfyui-handler.py
COPY handler.py /handler.py
COPY rp_handler.py /rp_handler.py
COPY test_input.json /test_input.json
COPY start_wrapper.sh /start_wrapper.sh
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
RUN chmod +x /start_wrapper.sh

CMD ["/start_wrapper.sh"]
