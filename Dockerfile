# Nodes only. All MiniMax-H3 weights live on the RunPod network volume
# mounted at /runpod-volume (see download_models.py / extra_model_paths.yaml).
FROM runpod/worker-comfyui:5.8.4-base

RUN git clone https://github.com/yolain/ComfyUI-Easy-Use /comfyui/custom_nodes/ComfyUI-Easy-Use && cd /comfyui/custom_nodes/ComfyUI-Easy-Use && (git checkout 5618a748c14858a6e95a583baa28bb7c8da7976a 2>/dev/null || (git fetch origin 5618a748c14858a6e95a583baa28bb7c8da7976a --depth=1 && git checkout 5618a748c14858a6e95a583baa28bb7c8da7976a) || echo "WARN: commit 5618a748c14858a6e95a583baa28bb7c8da7976a unreachable in https://github.com/yolain/ComfyUI-Easy-Use, falling back to default branch HEAD")
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts /comfyui/custom_nodes/ComfyUI-Custom-Scripts && cd /comfyui/custom_nodes/ComfyUI-Custom-Scripts && (git checkout 609f3afaa74b2f88ef9ce8d939626065e3247469 2>/dev/null || (git fetch origin 609f3afaa74b2f88ef9ce8d939626065e3247469 --depth=1 && git checkout 609f3afaa74b2f88ef9ce8d939626065e3247469) || echo "WARN: commit 609f3afaa74b2f88ef9ce8d939626065e3247469 unreachable in https://github.com/pythongosssss/ComfyUI-Custom-Scripts, falling back to default branch HEAD")
RUN git clone --depth 1 https://github.com/rgthree/rgthree-comfy /comfyui/custom_nodes/rgthree-comfy
RUN git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes /comfyui/custom_nodes/ComfyUI-KJNodes \
    && pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-KJNodes/requirements.txt
RUN comfy node install --exit-on-fail vsaan212-workflow-utilities
RUN git clone https://github.com/T8mars/comfyui-minimax-h3-blockcache-T8 /comfyui/custom_nodes/comfyui-minimax-h3-blockcache-T8
RUN git clone https://github.com/wjc573/ComfyUI-H3LatentUpscale-jingchen573 /comfyui/custom_nodes/ComfyUI-H3LatentUpscale-jingchen573
RUN git clone https://github.com/LBH-123-AI/Comfyui_Minimax_h3_latent_Upscaler /comfyui/custom_nodes/Comfyui_Minimax_h3_latent_Upscaler

RUN mkdir -p /opt && cp /handler.py /opt/worker-comfyui-handler.py
COPY handler.py /handler.py
COPY rp_handler.py /rp_handler.py
COPY test_input.json /test_input.json
COPY download_models.py /opt/download_models.py
COPY start_wrapper.sh /start_wrapper.sh
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
RUN chmod +x /start_wrapper.sh

CMD ["/start_wrapper.sh"]
