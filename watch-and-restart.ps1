Write-Host "Starting ComfyUI process..."
Start-Process -FilePath comfy -ArgumentList "--here", "launch", "--", "--listen"-WorkingDirectory "C:/app/ComfyUI" -RedirectStandardOutput "C:/app/ComfyUI/comfy_stdout.log" -RedirectStandardError "C:/app/ComfyUI/comfy_stderr.log"

Write-Host "Waiting a few seconds for ComfyUI to initialize..."
Start-Sleep -Seconds 10 # Give it time to start and potentially write logs/errors

# --- Log File Paths ---
$comfyStdOutPath = "C:/app/ComfyUI/comfy_stdout.log"
$comfyStdErrPath = "C:/app/ComfyUI/comfy_stderr.log"
$idleThresholdMinutes = 240

while ($true) {
  Start-Sleep -Seconds 999

  # --- Optional: Display recent logs ---
  if (Test-Path $comfyStdErrPath) {
      $errorContent = Get-Content $comfyStdErrPath -Tail 10 -ErrorAction SilentlyContinue # Show recent errors
      if ($errorContent) {
          Write-Host "--- Recent ComfyUI Stderr ---"
          Write-Host ($errorContent -join "`n")
          Write-Host "--------------------------"
      }
  }
  # You could add a similar block for stdout if needed for debugging

  # --- Idle Check based on Log File Modification Time ---
  if (Test-Path $comfyStdOutPath) {
    try {
      $logFile = Get-Item $comfyStdOutPath -ErrorAction Stop
      $timeSinceLastWrite = (Get-Date) - $logFile.LastWriteTime
      Write-Host "Log file '$($logFile.Name)' last written $($timeSinceLastWrite.TotalMinutes.ToString("F2")) minutes ago."

      if ($timeSinceLastWrite.TotalMinutes -gt $idleThresholdMinutes) {
        Write-Host "Idle threshold ($idleThresholdMinutes minutes) exceeded based on log file modification time. Stopping process..."
        Stop-Process -Name comfy -Force -ErrorAction SilentlyContinue
        Write-Host "Exiting script."
        exit 0 # Exit the script
      }
    } catch {
        Write-Warning "Error accessing log file '$comfyStdOutPath': $($_.Exception.Message)"
        # Decide how to handle this - maybe continue, maybe exit after a few tries? For now, continue.
    }
  } else {
    # Log file doesn't exist yet. This might be okay initially.
    # Consider adding logic here if the log file *should* exist after a certain startup period.
    Write-Host "Watchdog log file not found yet: $comfyStdOutPath. Process might still be starting."
  }
  # --- End Idle Check ---

}
