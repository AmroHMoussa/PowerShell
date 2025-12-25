$MSIPath = "\\xxx\xxx\PrinterInstallerClient.msi" #Define your SMB or Hotlink
$LogFile = "C:\temp\package.log"

if (Test-Path "HKLM:\SOFTWARE\PrinterLogic\PrinterInstaller") {
    exit 0
}

Start-Process -FilePath "msiexec.exe" -ArgumentList @(
    "/i"
    "`"$MSIPath`""
    "/qn+"                                  
    "ALLUSERS=1"
    "HOMEURL=xxx" #Define your printercloud URL
    "AUTHORIZATION_CODE=xxx" #Define your authorization code
    "/l*v"
    "`"$LogFile`""
) -Wait -WindowStyle Hidden -PassThru | Out-Null

exit 0