Get-Process -Name "OUTLOOK" -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "Closed Outlook processes."

$uninstallPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$product = Get-ItemProperty $uninstallPaths | Where-Object { $_.DisplayName -eq "Mimecast for Outlook 64-bit" }

if ($product -and $product.UninstallString) {

    if ($product.UninstallString -match '/[XI]{1}([{][A-F0-9]{8}-([A-F0-9]{4}-){3}[A-F0-9]{12}[}])') {
        $guid = $matches[1]
        Write-Host "Found: $($product.DisplayName) (Version: $($product.DisplayVersion)). GUID: $guid"
        
        $logPath = "$env:TEMP\MimecastUninstall.log"
        $args = "/x $guid /quiet /norestart /l*v `"$logPath`""
        Start-Process -FilePath "msiexec.exe" -ArgumentList $args -Wait -NoNewWindow
        
        if (Test-Path $logPath) {
            Write-Host "Uninstallation completed. Check log at: $logPath"
        } else {
            Write-Host "Uninstallation completed (no log generated)."
        }
    } else {
        Write-Host "Could not extract GUID from UninstallString: $($product.UninstallString)"
    }
} else {
    Write-Host "Mimecast for Outlook 64-bit not found in registry. Run the diagnostic script to verify."
}