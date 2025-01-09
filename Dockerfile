# Start from the eisai/comfy-ui Windows image
FROM eisai/comfy-ui:latest
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Set working directory
WORKDIR C:/app

# Install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Git
RUN choco install git -y --no-progress

# Update PATH environment variable
RUN $env:PATH = $env:PATH + ';C:/app/MinGit/cmd;C:/app/python_embeded;C:/app/python_embeded/Scripts'; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

# RUN update/update_comfyui.bat
# RUN python -m pip install --upgrade pip-system-certs
# Set working directory for node manager installation
RUN mkdir C:/app/base_custom_nodes
WORKDIR C:/app/base_custom_nodes

# Clone the ComfyUI-Manager repository
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git
# copy config.ini here
COPY config.ini C:/app/base_custom_nodes/ComfyUI-Manager/


WORKDIR C:/app

# Copy extra_model_paths.yaml to ComfyUI directory
COPY extra_model_paths.yaml C:/app/ComfyUI/

# Reset working directory to the ComfyUI root

