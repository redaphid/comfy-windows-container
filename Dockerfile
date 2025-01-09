# Start from the eisai/comfy-ui Windows image
FROM eisai/comfy-ui:latest
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Set working directory
WORKDIR C:/app

# Download MinGit
RUN Invoke-WebRequest 'https://github.com/git-for-windows/git/releases/download/v2.12.2.windows.2/MinGit-2.12.2.2-64-bit.zip' -OutFile MinGit.zip

# Extract MinGit
RUN Expand-Archive MinGit.zip -DestinationPath C:/app/MinGit

# Clean up zip file
RUN Remove-Item MinGit.zip

# Update PATH environment variable
RUN $env:PATH = $env:PATH + ';C:/app/MinGit/cmd'; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

# Set working directory for node manager installation
WORKDIR C:/app/ComfyUI/custom_nodes

# Clone the ComfyUI-Manager repository
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# Reset working directory to the ComfyUI root
WORKDIR C:/app
