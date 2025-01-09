Invoke-WebRequest 'https://github.com/git-for-windows/git/releases/download/v2.12.2.windows.2/MinGit-2.12.2.2-64-bit.zip' -OutFile MinGit.zip
Expand-Archive .\MinGit.zip
$env:PATH = $env:PATH + ';C:\app\MinGit\cmd\;C:\app\MinGit\cmd'; \
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $env:PATH
cd c:\app\ComfyUI\custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
