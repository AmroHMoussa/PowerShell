# Define variables
$Username = "xxx" #Define the local account user account
$NewPassword = "xxx" #Define the password
$SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force

# Check if the user exists
if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
    # Set the new password
    Set-LocalUser -Name $Username -Password $SecurePassword
    Write-Host "Password for '$Username' has been successfully reset."
} else {
    Write-Host "User '$Username' does not exist."
}