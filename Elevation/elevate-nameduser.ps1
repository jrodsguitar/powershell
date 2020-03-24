#Script by Jose Rodriguez
#3/23/2020
# New PS Process
$newpowershellprocess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";

#Store Creds
#Promt for username and password.
$username = Read-Host "Enter username"
$password = Read-Host  -AsSecureString "Enter Password"
#$creds = New-Object System.Management.Automation.PSCredential($username, $password)

#Logic to populate username
if ($username -like "*\*") {

    $newpowershellprocessDomain = ($username -split '\\')[0]
    $newpowershellprocessUserName = ($username -split '\\')[1]

}
else {

    $newpowershellprocessUserName = $username

}

#Populate newprocess properties
$newpowershellprocess.Arguments = "-noprofile -command &{start-process powershell.exe -verb runas }"
$newpowershellprocess.Domain = $newpowershellprocessDomain
$newpowershellprocess.UserName = $newpowershellprocessUserName
$newpowershellprocess.password = $password 
$newpowershellprocess.UseShellExecute = $false
    
#The key to this. Run in an elevated manner
$newpowershellprocess.Verb = "runas"

# Start process
[System.Diagnostics.Process]::Start($newpowershellprocess)

#The punchline here is that the below line also does the same things as lines 10-20 above.
#Left here as an example of how to do the same thing in powershell in a different manner
#Start-Process powershell -Credential $creds -ArgumentList '-noprofile -command &{Start-Process powershell -verb runas}'