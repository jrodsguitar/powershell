##I recently saw a question on the Facebook Power Scripting group that reminded me of a time that I needed to connect to a remote machine with PowerShell,##
##and run commands from a module, that only existed in the machine I was connecting from.##

##I thought I would take a stab at rewriting it and posting it here##

##The premise of it is that we currently have a way in PowerShell to import commands from a remote session.##
##We do this with either import-pssession or export-pssession, where export-pssession actually copies files locally to our module directory##

##However we cannot go in the reverse direction. Can't easily run local modules remotely.##

##What the below script does is to export our local module cmdlets, functions, and aliases for a specific module of our choice, and then it creates the module on the remote machine.##

#Get Credentials#
$cred = Get-Credential

#Start a new PSSession#
$session = New-PSSession -ComputerName 10.250.250.184 -Credential $cred

#This is the name of the local module tht you want to use be able to use in your remote pssession
$nameoflocalmodule = "whatever"

#Lookup module
$localpsmodulename = Get-Module $nameoflocalmodule

#Store module definition
$localpsmoduledefinition = $localpsmodulename.Definition

#Store functions, cmdlets, and aliases for later use
$exportedfunctions =$($localpsmodulename.ExportedFunctions.keys -join ",")
$exportedcmdlets =$($localpsmodulename.ExportedFunctions.keys -join ",")
$exportedaliases =$($localpsmodulename.ExportedFunctions.keys -join ",")

#Here you can do this any number of ways (Storing commands for later use but this seems to work well fot this purpose)
#Check if module already exists 
$command = "try{if($checkmodule){Remove-Module $($localpsmodulename.Name)}} catch{}"

#This takes the exported module items above and creates a new module on the remote machine that where we have a pssession on
$command2 = "New-Module -Name $($localpsmodulename.Name) {$($localpsmoduledefinition);Export-ModuleMember -Verbose -Cmdlet $exportedcmdlets -Function $exportedfunctions -Alias $exportedaliases;} | Import-Module;"

#Run the actual commands above `$command` and `$command2` on a remote machine. 
#This is what then allows you to access the local module in that remote machine so remove the script block below and run the command you need from the module
$results = Invoke-Command -Session $session -ScriptBlock {invoke-expression $using:command;invoke-expression $using:command2;<#run module command here. Remove this comment block obviously#>;}

#Dump the results from our invoke-command. This can be done in other ways.
$results

#Finally we remove the pssession
Remove-PSSession $session