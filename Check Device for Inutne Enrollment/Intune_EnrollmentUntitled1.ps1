
$IntuneEnrolled = 0

$IntuneVerdict  = "NOT INTUNE ENROLLED"


#Get Device / MDM state via dsregcmd

$AzureAdJoined   = $false

$DomainJoined    = $false

$WorkplaceJoined = $false

$MdmUrl          = $null



try {

    $dsreg = dsregcmd /status 2>$null



    if ($dsreg -match 'AzureAdJoined\s*:\s*YES')   { $AzureAdJoined   = $true }

    if ($dsreg -match 'DomainJoined\s*:\s*YES')    { $DomainJoined    = $true }

    if ($dsreg -match 'WorkplaceJoined\s*:\s*YES') { $WorkplaceJoined = $true }



    $mdmLine = $dsreg | Select-String -Pattern 'MdmUrl\s*:\s*(\S+)'

    if ($mdmLine) {

        $MdmUrl = ($mdmLine.Matches[0].Groups[1].Value).Trim()

    }

}

catch {

    Write-Warning "Could not run dsregcmd: $($_.Exception.Message)"

}



#MDM enrollment registry entries

$EnrolledViaMSDMServer = $false

$EnrollmentUPN         = $null

$EnrollmentType        = $null



$enrollRoot = "HKLM:\SOFTWARE\Microsoft\Enrollments"



if (Test-Path $enrollRoot) {

    $enrollments = Get-ChildItem $enrollRoot -ErrorAction SilentlyContinue |

        Get-ItemProperty -ErrorAction SilentlyContinue |

        Where-Object { $_.ProviderID -eq "MS DM Server" }



    if ($enrollments) {

        $EnrolledViaMSDMServer = $true

        $first = $enrollments | Select-Object -First 1

        $EnrollmentUPN  = $first.UPN

        $EnrollmentType = $first.EnrollmentType

    }

}



#Check for Intune Management Extension

$IMEPresent = $false

$IMERunning = $false



$ime = Get-Service -Name IntuneManagementExtension -ErrorAction SilentlyContinue

if ($ime) {

    $IMEPresent = $true

    if ($ime.Status -eq 'Running') { $IMERunning = $true }

}


#set OUTPUT PARAMETERS

if ($EnrolledViaMSDMServer) {

    $IntuneEnrolled = 1

    $IntuneVerdict  = "INTUNE ENROLLED"

}

else {

    $IntuneEnrolled = 0

    $IntuneVerdict  = "NOT INTUNE ENROLLED"

}


$amStatus = [PSCustomObject]@{

    ComputerName          = $env:COMPUTERNAME

    Verdict               = $IntuneVerdict

    IntuneEnrolled        = $IntuneEnrolled

    AzureAdJoined         = $AzureAdJoined

    DomainJoined          = $DomainJoined

    WorkplaceJoined       = $WorkplaceJoined

    MdmUrl                = $MdmUrl

    EnrolledViaMSDMServer = $EnrolledViaMSDMServer

    EnrollmentUPN         = $EnrollmentUPN

    EnrollmentType        = $EnrollmentType

    IMEPresent            = $IMEPresent

    IMERunning            = $IMERunning

}



$amStatus | Format-List | Out-String | Write-Output