#!/bin/false

# This file will be sourced in init.sh

# forked from https://raw.githubusercontent.com/ai-dock/stable-diffusion-webui/main/config/provisioning/default.sh
printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"

function download() {
    wget -q --show-progress -e dotbytes="${3:-4M}" -O "$2" "$1"
}
disk_space=$(df --output=avail -m $WORKSPACE|tail -n1)
webui_dir=/opt/stable-diffusion-webui
models_dir=${webui_dir}/models
sd_models_dir=${models_dir}/Stable-diffusion
extensions_dir=${webui_dir}/extensions
cn_models_dir=${extensions_dir}/sd-webui-controlnet/models
vae_models_dir=${models_dir}/VAE
upscale_models_dir=${models_dir}/ESRGAN

printf "Downloading extensions..."
cd $extensions_dir

# Controlnet
printf "Setting up Controlnet...\n"
if [[ -d sd-webui-controlnet ]]; then
    (cd sd-webui-controlnet && \
        git pull && \
        micromamba run -n webui ${PIP_INSTALL} -r requirements.txt
    )
else
    (git clone https://github.com/Mikubill/sd-webui-controlnet && \
         micromamba run -n webui ${PIP_INSTALL} -r sd-webui-controlnet/requirements.txt
    )
fi

# Image Browser
printf "Setting up Image Browser...\n"
if [[ -d stable-diffusion-webui-images-browser ]]; then
    (cd stable-diffusion-webui-images-browser && git pull)
else
    git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser
fi

# Ultimate Upscale
printf "Setting up Ultimate Upscale...\n"
if [[ -d ultimate-upscale-for-automatic1111 ]]; then
    (cd ultimate-upscale-for-automatic1111 && git pull)
else
    git clone https://github.com/Coyote-A/ultimate-upscale-for-automatic1111
fi

# Clip Interrogator
printf "Setting up Clip Interrogator...\n"
if [[ -d clip-interrogator-ext ]]; then
    (cd clip-interrogator-ext && git pull && \
            micromamba run -n webui ${PIP_INSTALL} clip-interrogator==0.6.0)
else
    git clone https://github.com/pharmapsychotic/clip-interrogator-ext
    micromamba run -n webui ${PIP_INSTALL} clip-interrogator==0.6.0
fi

# deliberate_v3
printf "Downloading Deliberate v3...\n"
model_file=${sd_models_dir}/deliberate_v3.safetensors
model_url=https://huggingface.co/XpucT/Deliberate/resolve/main/Deliberate_v3.safetensors

printf "Downloading a few pruned controlnet models...\n"

model_file=${cn_models_dir}/control_canny-fp16.safetensors
model_url=https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_canny-fp16.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Canny...\n"
    download ${model_url} ${model_file}
fi

model_file=${cn_models_dir}/control_v11p_sd15_lineart.pth
model_url=https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_lineart.pth

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Lineart...\n"
    download ${model_url} ${model_file}
fi

model_file=${cn_models_dir}/annotator/downloads/lineart/sk_model.pth
model_url=https://huggingface.co/lllyasviel/Annotators/resolve/main/sk_model.pth

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Lineart annotator...\n"
    download ${model_url} ${model_file}
fi

model_file=${cn_models_dir}/control_scribble-fp16.safetensors
model_url=https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_scribble-fp16.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Scribble...\n"
    download ${model_url} ${model_file}
fi

printf "Downloading VAE...\n"

model_file=${vae_models_dir}/vae-ft-ema-560000-ema-pruned.safetensors
model_url=https://huggingface.co/stabilityai/sd-vae-ft-ema-original/resolve/main/vae-ft-ema-560000-ema-pruned.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading vae-ft-ema-560000-ema...\n"
    download ${model_url} ${model_file}
fi

model_file=${vae_models_dir}/vae-ft-mse-840000-ema-pruned.safetensors
model_url=https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading vae-ft-mse-840000-ema...\n"
    download ${model_url} ${model_file}
fi

printf "Downloading Upscalers...\n"

model_file=${upscale_models_dir}/4x_foolhardy_Remacri.pth
model_url=https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth

if [[ ! -e ${model_file} ]]; then
    printf "Downloading 4x_foolhardy_Remacri...\n"
    download ${model_url} ${model_file}
fi

model_file=${upscale_models_dir}/4x_NMKD-Siax_200k.pth
model_url=https://huggingface.co/Akumetsu971/SD_Anime_Futuristic_Armor/resolve/main/4x_NMKD-Siax_200k.pth

if [[ ! -e ${model_file} ]]; then
    printf "Downloading 4x_NMKD-Siax_200k...\n"
    download ${model_url} ${model_file}
fi

model_file=${upscale_models_dir}/RealESRGAN_x4.pth
model_url=https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth

if [[ ! -e ${model_file} ]]; then
    printf "Downloading RealESRGAN_x4...\n"
    download ${model_url} ${model_file}
fi

printf "\nProvisioning complete:  Web UI will start now\n\n"

