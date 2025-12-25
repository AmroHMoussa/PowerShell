# Restart-DefenderServices.ps1
# Compatible with: Windows 10/11, Server 2016-2022, All PowerShell versions
# Restarts core Microsoft Defender services and attempts basic recovery

$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Color = "White")
    $colors = @{ "Red"="Red"; "Green"="Green"; "Yellow"="Yellow"; "Cyan"="Cyan"; "White"="White" }
    Write-Host $Message -ForegroundColor $colors[$Color]
}

Write-Status "Starting Microsoft Defender service recovery..." "Cyan"

# List of Defender services to restart
$Services = @(
    @{ Name = "WinDefend"; Display = "Microsoft Defender Antivirus Service" }
    @{ Name = "WdNisSvc";  Display = "Microsoft Defender Antivirus Network Inspection Service" }
    @{ Name = "MDCoreSvc"; Display = "Microsoft Defender Core Service" }
)

$Restarted = $false

foreach ($svc in $Services) {
    try {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($null -eq $service) {
            Write-Status "Warning: $($svc.Display) ($($svc.Name)) not found on this system." "Yellow"
            continue
        }

        Write-Status "Processing: $($svc.Display)" "White"

        # Set to Automatic if not already
        if ($service.StartType -notin @("Automatic", "Manual")) {
            Write-Status "  Setting startup type to Automatic..." "Cyan"
            Set-Service -Name $svc.Name -StartupType Automatic -ErrorAction Stop
        }

        # Restart if running or stopped
        if ($service.Status -eq "Running") {
            Write-Status "  Restarting $($svc.Name)..." "Cyan"
            Restart-Service -Name $svc.Name -Force -ErrorAction Stop
            $Restarted = $true
        }
        elseif ($service.Status -eq "Stopped") {
            Write-Status "  Starting $($svc.Name)..." "Cyan"
            Start-Service -Name $svc.Name -ErrorAction Stop
            $Restarted = $true
        }
        else {
            Write-Status "  Status: $($service.Status) - No action taken." "Yellow"
        }

        # Verify it's running
        $service = Get-Service -Name $svc.Name
        if ($service.Status -eq "Running") {
            Write-Status "  Success: $($svc.Name) is now Running." "Green"
        } else {
            Write-Status "  Failed: $($svc.Name) is $($service.Status)." "Red"
        }
    }
    catch {
        Write-Status "  Error: $($_.Exception.Message)" "Red"
    }
}

#Additional Recovery Steps

Write-Status "`nRunning additional recovery steps..." "Cyan"

# 1. Reset Windows Defender via MpCmdRun
try {
    $mpCmdRun = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    if (Test-Path $mpCmdRun) {
        Write-Status "Running MpCmdRun -RestoreDefaults..." "Cyan"
        & $mpCmdRun -RestoreDefaults | Out-Null
        Write-Status "MpCmdRun restore completed." "Green"
    }
}
catch { Write-Status "MpCmdRun failed: $($_.Exception.Message)" "Red" }

# 2. Re-register Defender PowerShell module
try {
    Write-Status "Re-registering Defender PowerShell module..." "Cyan"
    $module = "Microsoft Defender"
    if (Get-Module -ListAvailable -Name "Defender") {
        Import-Module Defender -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Status "Defender module ready." "Green"
}
catch { Write-Status "Module re-registration skipped." "Yellow" }

# 3. Trigger signature update
try {
    Write-Status "Triggering definition update..." "Cyan"
    Update-MpSignature -ErrorAction SilentlyContinue | Out-Null
    Write-Status "Definition update initiated." "Green"
}
catch { Write-Status "Update-MpSignature not available or failed." "Yellow" }

# Final status
if ($Restarted) {
    Write-Status "`nDefender services have been restarted and recovered." "Green"
    Write-Status "Please wait 2-5 minutes for full initialization." "White"
} else {
    Write-Status "`nNo services were restarted. Check event logs or group policy." "Yellow"
}

Write-Status "`nScript completed. Reboot recommended if issues persist." "Cyan"