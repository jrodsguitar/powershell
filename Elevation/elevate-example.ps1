##How do you run a self elevating PowerShell script? 

##I've often encountered situations where I had to run a self elevating PowerShell script for various reasons.


##This script spawns a PowerShell process as an elevevated user (think UAC / Adminstrator elevation).##

#-
#Example of how to self elevate as Administrator(UAC) with alternate credentials.
#Script by Jose Rodriguez
#3/24/2020
#

#Starts an elevated shell as an alternate user and prompts for credentials.

$username = Read-Host "Enter username"
$password = Read-Host  -AsSecureString "Enter Password"
$creds =   New-Object System.Management.Automation.PSCredential($username,$password)

$runthis = {
    #Command that we intend to run after elevation.
}
#-

##Now we take the credentials and command from above and we start a new powershell process in an elevated manner.##

##In essense, Start-Process calls powershell with given credentials. Then powershell calls Start-Process which calls powershell, which is what finally runs ours command. Confused yet? :) ##

#-
Start-Process powershell -Credential $creds -ArgumentList "-noprofile -command &{start-process powershell.exe {$runthis} -verb runas}"
#-