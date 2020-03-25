#Example of how to self elevate as Administrator(UAC) with alternate credentials.
#Script by Jose Rodriguez
#3/24/2020
#Starts an elevated shell as an alternate user. Prompts for credentials.

$username = Read-Host "Enter username"
$password = Read-Host  -AsSecureString "Enter Password"
$creds =   New-Object System.Management.Automation.PSCredential($username,$password)

$runthis = {

    #Run your commands here.

}


#If you're new to PowerShell this line will kick your ass.
#Start a new powershell process with alternate credentials
#Next it tells that process to start a new powershell process in an elevated manner.
Start-Process powershell -Credential $creds -ArgumentList "-noprofile -command &{start-process powershell.exe {$runthis} -verb runas}"