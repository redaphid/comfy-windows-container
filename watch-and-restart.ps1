Write-Host "Starting ComfyUI process..."
Start-Process -FilePath comfy -ArgumentList "--here", "launch", "--", "--listen" -WorkingDirectory "C:/app/ComfyUI" -RedirectStandardOutput "C:/app/ComfyUI/comfy_stdout.log" -RedirectStandardError "C:/app/ComfyUI/comfy_stderr.log"

# --- Log File Paths ---
$comfyStdOutPath = "C:/app/ComfyUI/comfy_stdout.log"
$comfyStdErrPath = "C:/app/ComfyUI/comfy_stderr.log"
$idleThresholdMinutes = 120

while ($true) {
  Start-Sleep -Seconds 120

  # --- Optional: Display recent logs ---
  if (Test-Path $comfyStdErrPath) {
      $errorContent = Get-Content $comfyStdErrPath -Tail 10 -ErrorAction SilentlyContinue # Show recent errors
      if ($errorContent) {
          Write-Host "--- Recent ComfyUI Stderr $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ---"
          Write-Host ($errorContent -join "`n")
          Write-Host "---------------------------------------------------"
      }
  }
  if (Test-Path $comfyStdOutPath) {
      $outputContent = Get-Content $comfyStdOutPath -Tail 10 -ErrorAction SilentlyContinue # Show recent output
      if ($outputContent) {
          Write-Host "--- Recent ComfyUI Stdout $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ---"
          Write-Host ($outputContent -join "`n")
          Write-Host "----------------------------------------------------"
      }
  }
  # You could add a similar block for stdout if needed for debugging

  # --- Idle Check based on Log File Modification Time ---
  if (Test-Path $comfyStdOutPath) {
    try {
      $logFile = Get-Item $comfyStdOutPath -ErrorAction Stop
      $timeSinceLastWrite = (Get-Date) - $logFile.LastWriteTime
      Write-Host "-------------------------- Debug Info --------------------------"
      Write-Host "Current Time:          $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
      Write-Host "Log Last Write Time:   $($logFile.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))"
      Write-Host "Calculated Idle Time:  $($timeSinceLastWrite.TotalMinutes.ToString("F2")) minutes"
      Write-Host "Idle Threshold:        $idleThresholdMinutes minutes"
      Write-Host "----------------------------------------------------------------"

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
