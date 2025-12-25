# Variables
$Url = "https://downloads.1password.com/win/1PasswordSetup-latest.msi"
$DownloadPath = "C:\Temp"
$MsiName = "1PasswordSetup-latest.msi"
$MsiPath = Join-Path $DownloadPath $MsiName

# Ensure C:\Temp exists
if (!(Test-Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath -Force
}

# Download the MSI
Invoke-WebRequest -Uri $Url -OutFile $MsiPath -UseBasicParsing

# Install the MSI silently
$process = Start-Process -FilePath "msiexec.exe" `
    -ArgumentList "/i `"$MsiPath`" /qn /norestart" `
    -Wait -PassThru

# Optional: return exit code
exit $process.ExitCode