# Define variables
$Username = "xxx" #Define the username
$Password = "xxx" #Define the password
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Check if user already exists
if (-Not (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue)) {
    # Create the local user with password never expiring
    New-LocalUser -Name $Username -Password $SecurePassword -FullName "xxx" -Description "Local admin account created by script" -PasswordNeverExpires #Replace xxx with the Fullname
    Write-Host "User '$Username' created successfully."
} else {
    Write-Host "User '$Username' already exists."
}

# Add user to Administrators group
Add-LocalGroupMember -Group "Administrators" -Member $Username
Write-Host "User '$Username' added to Administrators group."
