# Import the Active Directory module
Import-Module ActiveDirectory

# Define the export file path
$outputPath = "C:\Temp\ActiveADUsers.csv"

# Ensure the output folder exists
if (-not (Test-Path -Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp"
}

# Get active users and exclude those starting with 'A_' or 'svc'
$activeUsers = Get-ADUser -Filter {
    Enabled -eq $true -and 
    -not(SamAccountName -like "A_*") -and 
    -not(SamAccountName -like "svc*")
} -Properties DisplayName, EmailAddress, LastLogonDate

# Select the desired fields
$exportData = $activeUsers | Select-Object `
    SamAccountName,
    DisplayName,
    EmailAddress,
    LastLogonDate

# Export to CSV
$exportData | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

# Confirmation message
Write-Host "✅ Export complete. File saved to: $outputPath"
