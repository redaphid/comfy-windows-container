# Use Windows Server Core with Python
FROM python:3.12.8-windowsservercore-ltsc2022

# Install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Git and Visual C++ Redistributable
RUN choco install git -y --no-progress; \
    choco install vcredist140 -y --no-progress

# pip install comfy-cli with verbose output
RUN python -m pip install --upgrade pip-system-certs
RUN python -m pip install comfy-cli
# Create and set working directory
RUN mkdir -p C:/app
WORKDIR C:/app

RUN comfy --skip-prompt --here install --nvidia --fast-deps
WORKDIR C:/app/ComfyUI
# Copy configuration files
COPY config.ini C:/app/ComfyUI/custom_nodes/ComfyUI-Manager/
COPY extra_model_paths.yaml .
# Update ComfyUI
RUN comfy --here update

# Copy the watchdog script
COPY watch-and-restart.ps1 /app/

# Set the entrypoint to run the watchdog script
# The script will start ComfyUI and monitor it
ENTRYPOINT ["powershell", "-File", "C:/app/watch-and-restart.ps1"]
