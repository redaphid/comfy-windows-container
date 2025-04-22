Write-Host "Starting ComfyUI process..."
Start-Process -FilePath comfy -ArgumentList "--here", "launch", "--", "--listen"-WorkingDirectory "C:/app/ComfyUI" -RedirectStandardOutput "C:/app/ComfyUI/comfy_stdout.log" -RedirectStandardError "C:/app/ComfyUI/comfy_stderr.log"

Write-Host "Waiting a few seconds for ComfyUI to initialize..."
Start-Sleep -Seconds 10 # Give it time to start and potentially write logs/errors

$lastHit = Get-Date

while ($true) {
  Start-Sleep -Seconds 60

  # Check for ComfyUI's own logs (if they exist)
  $comfyStdOutPath = "C:/app/ComfyUI/comfy_stdout.log"
  $comfyStdErrPath = "C:/app/ComfyUI/comfy_stderr.log"
  if (Test-Path $comfyStdErrPath) {
      $errorContent = Get-Content $comfyStdErrPath -Raw -ErrorAction SilentlyContinue
      if ($errorContent) {
          Write-Host "--- ComfyUI Stderr ---"
          Write-Host $errorContent
          Write-Host "---------------------"
      }
  }
  if (Test-Path $comfyStdOutPath) {
      $outputContent = Get-Content $comfyStdOutPath -Raw -ErrorAction SilentlyContinue
      # Optional: You might want to print stdout too for debugging, but it could be verbose
      # if ($outputContent) {
      #     Write-Host "--- ComfyUI Stdout ---"
      #     Write-Host $outputContent
      #     Write-Host "---------------------"
      # }
  }

  # --- Watchdog Log Check ---
  # Monitor the stdout log we are redirecting
  $logPathToCheck = $comfyStdOutPath
  $activityPattern = "(GET|POST) /" # Look for GET or POST requests in stdout

  if (Test-Path $logPathToCheck) {
    # Get the last N lines (adjust N if needed)
    $logContent = Get-Content $logPathToCheck -Tail 50 -ErrorAction SilentlyContinue
    if ($logContent -match $activityPattern) {
      Write-Host "Activity pattern '$activityPattern' detected in $logPathToCheck at $(Get-Date)"
      $lastHit = Get-Date
    }
  } else {
    # This might happen briefly at the start
    Write-Host "Watchdog log file not found yet: $logPathToCheck"
  }
  # --- End Watchdog Log Check ---


  $idleTime = (Get-Date) - $lastHit
  Write-Host "Current idle time: $($idleTime.TotalMinutes) minutes"

  if ($idleTime.TotalMinutes -gt 10) {
    Write-Host "Idle threshold exceeded. Stopping process..."
    Stop-Process -Name comfy -Force -ErrorAction SilentlyContinue
    Write-Host "Exiting script."
    exit 0 # Exit the script, which should stop the container if this is the main process
  }
}
