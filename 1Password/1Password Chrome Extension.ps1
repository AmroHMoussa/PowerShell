# Chrome Extension ID for 1Password
$ExtensionID = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"

# Chrome Web Store update URL
$UpdateURL = "https://clients2.google.com/service/update2/crx"

# Registry path for Chrome force-installed extensions
$RegPath = "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist"

# Create the registry path if it doesn't exist
if (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Find next available numeric value name
$ExistingValues = (Get-Item $RegPath).GetValueNames() | Where-Object { $_ -match '^\d+$' }
$NextValue = if ($ExistingValues) {
    ([int]($ExistingValues | Measure-Object -Maximum).Maximum + 1).ToString()
} else {
    "1"
}

# Set the extension to force install
New-ItemProperty `
    -Path $RegPath `
    -Name $NextValue `
    -Value "$ExtensionID;$UpdateURL" `
    -PropertyType String `
    -Force | Out-Null

Write-Output "1Password Chrome extension has been added. Restart Chrome to complete installation."
