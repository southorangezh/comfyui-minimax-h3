# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""

# install custom nodes into comfyui
RUN git clone https://github.com/yolain/ComfyUI-Easy-Use /comfyui/custom_nodes/ComfyUI-Easy-Use && cd /comfyui/custom_nodes/ComfyUI-Easy-Use && (git checkout 5618a748c14858a6e95a583baa28bb7c8da7976a 2>/dev/null || (git fetch origin 5618a748c14858a6e95a583baa28bb7c8da7976a --depth=1 && git checkout 5618a748c14858a6e95a583baa28bb7c8da7976a) || echo "WARN: commit 5618a748c14858a6e95a583baa28bb7c8da7976a unreachable in https://github.com/yolain/ComfyUI-Easy-Use, falling back to default branch HEAD")
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts /comfyui/custom_nodes/ComfyUI-Custom-Scripts && cd /comfyui/custom_nodes/ComfyUI-Custom-Scripts && (git checkout 609f3afaa74b2f88ef9ce8d939626065e3247469 2>/dev/null || (git fetch origin 609f3afaa74b2f88ef9ce8d939626065e3247469 --depth=1 && git checkout 609f3afaa74b2f88ef9ce8d939626065e3247469) || echo "WARN: commit 609f3afaa74b2f88ef9ce8d939626065e3247469 unreachable in https://github.com/pythongosssss/ComfyUI-Custom-Scripts, falling back to default branch HEAD")
RUN comfy node install --exit-on-fail rgthree-comfy --mode remote
RUN comfy node install --exit-on-fail comfyui-kjnodes
RUN comfy node install --exit-on-fail vsaan212-workflow-utilities
RUN git clone https://github.com/T8mars/comfyui-minimax-h3-blockcache-T8 /comfyui/custom_nodes/comfyui-minimax-h3-blockcache-T8
RUN git clone https://github.com/wjc573/ComfyUI-H3LatentUpscale-jingchen573 /comfyui/custom_nodes/ComfyUI-H3LatentUpscale-jingchen573
RUN git clone https://github.com/LBH-123-AI/Comfyui_Minimax_h3_latent_Upscaler /comfyui/custom_nodes/Comfyui_Minimax_h3_latent_Upscaler

# download models into comfyui
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/lightx2v/Minimax-h3-Turbo/resolve/main/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors' --relative-path models/loras --filename 'minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors' --relative-path models/diffusion_models --filename 'minimax_h3_fl2va_pruned_int8_convrot.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Gluttony10/MiniMax-H3-INT8-CONVROT/resolve/main/MiniMax-H3-FL2VA-int8_convrot.safetensors' --relative-path models/diffusion_models --filename 'MiniMax-H3-FL2VA-int8-convrot.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors' --relative-path models/text_encoders --filename 'qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors' --relative-path models/text_encoders --filename 'qwen3vl_32b_minimax_h3_int8_convrot.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_video_vae_fp16.safetensors' --relative-path models/vae --filename 'minimax_h3_video_vae_fp16.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors' --relative-path models/vae --filename 'minimax_h3_audio_vae_fp32.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/orangesouth/MinimaxH3CinematicRealism/resolve/main/Minimax%20H3%E7%9C%9F%E5%AE%9E%E7%94%B5%E5%BD%B1%E8%B4%A8%E6%84%9FV0.1.safetensors' --relative-path models/loras --filename '电影镜头_000019000.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/LBH-123-AI/Minimax_h3_latent_Upscaler/resolve/main/minimax_h3_latent_upscaler_3d_bf16.safetensors' --relative-path models/Unknown --filename 'minimax_h3_latent_upscaler_3d_bf16.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# Keep the worker-comfyui handler, then overlay repo handler.py so RunPod
# GitHub detection sees runpod.serverless.start() in the image too.
RUN cp /handler.py /opt/worker-comfyui-handler.py
COPY handler.py /handler.py
COPY rp_handler.py /rp_handler.py
COPY test_input.json /test_input.json

# /start.sh starts ComfyUI, then runs `python -u /handler.py`
CMD ["/start.sh"]
