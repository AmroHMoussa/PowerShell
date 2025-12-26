# Start OneDrive if it's not already running

$OneDriveProcess = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue

if (-not $OneDriveProcess) {
    Write-Host "OneDrive is not running. Starting OneDrive..." -ForegroundColor Yellow
    
    # Start the standalone OneDrive client (most common for personal and work/school accounts)
    Start-Process -FilePath "$env:USERPROFILE\AppData\Local\Microsoft\OneDrive\OneDrive.exe" -ArgumentList "/background"
    
    # Alternative paths (uncomment if the above doesn't work on some machines)
    # Start-Process -FilePath "$env:PROGRAMFILES\Microsoft OneDrive\OneDrive.exe" -ArgumentList "/background"
    # Start-Process -FilePath "$env:PROGRAMFILES (x86)\Microsoft OneDrive\OneDrive.exe" -ArgumentList "/background"
}
else {
    Write-Host "OneDrive is already running (PID: $($OneDriveProcess.Id)). No action taken." -ForegroundColor Green
}