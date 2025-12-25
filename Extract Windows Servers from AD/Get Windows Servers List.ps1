# Import Active Directory module
Import-Module ActiveDirectory

# Ensure C:/temp directory exists
$tempPath = "C:\temp"
if (-not (Test-Path $tempPath)) {
    New-Item -ItemType Directory -Path $tempPath | Out-Null
}

# Get all Windows servers from Active Directory
$servers = Get-ADComputer -Filter {OperatingSystem -like "*Windows Server*"} -Properties LastLogonDate

# Export server name and last logon date to CSV
$servers | Select-Object Name, LastLogonDate | Sort-Object LastLogonDate -Descending | 
Export-Csv -Path "$tempPath\ServerLastLogon.csv" -NoTypeInformation