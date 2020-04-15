<#
.Synopsis
    Finds which apps run automatically on startup on workstations or servers.

.DESCRIPTION
    See Above.
    
.EXAMPLE
    Get-AutoRuns -ComputerName <Computer Name> 
       
    This example will identify which apps run automatically on startup on a single computer. Note: There will be an output file will be dumped to the desktop by default and called AutoRuns.csv.
          
.EXAMPLE
    Get-AutoRuns -ComputerName <Computer Name, Computer Name> -OutputPath "c:\AutoRuns.csv"
          
    This example will identify which apps run automatically on startup on multiple computers and will output the csv file to "c:\AutoRuns.csv" defined by the OutputPath parameter above.
          
.EXAMPLE
    Get-AutoRuns -ComputerName $(Get-Content C:\computers.txt) 
    
    This example will identify which apps run automatically on startup on multiple computers that are imported from a file.
        
.EXAMPLE
    Get-AutoRuns -OUPath <"OU=Computers,DC=Domain,DC=Com"> 
    
    This example will identify which apps run automatically on startup on any computers found within the distinguished name path that is defined using the -OUPath parameter.
    
 .AUTHOR
    Sir Addison
 #>

 function Get-AutoRuns
 {
     [CmdletBinding(DefaultParameterSetName=’ComputerName’)]
     [Alias('GAA')]
     Param
     (
         # The input for this parameter is the Computer hostname to which you want to collect Auto Run data.
         [Parameter(Mandatory=$false,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0,
                    ParameterSetName=’ComputerName’)]            
         [array]$ComputerName = $env:COMPUTERNAME,
 
         [Parameter(Mandatory=$false,
                    Position=0,
                    ParameterSetName=’OUPath’)]
         # Distinguished Name path of which Organizational Unit you would like to find computers in.
         $OUPath,
 
         [Parameter(Mandatory=$false,
                    Position=1)]
         # Path on the computer where you would like the output file.
         $OutputPath = "$env:USERPROFILE\Desktop\AutoRuns.csv"        
 )
 
 If($OUPath){$ComputerName = (Get-ADComputer -Filter * -SearchBase $OUPath).Name}
 
 $DataSets =@()
 foreach ($thing in $ComputerName){
     $command ={
         try{
             #Registry Keys in which the script is looking for autorun applications.
             $keys = @(
                 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\privacy',
                 "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\BootExecute",
                 "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Notify",
                 "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit",
                 "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\\Shell",
                 "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\\Shell",
                 "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ShellServiceObjectDelayLoad",
                 "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\",
                 "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\",
                 "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\",
                 "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx\",
                 "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\",
                 "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run\",
                 "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run\",
                 "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices\",
                 "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices",
                 "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServicesOnce",
                 "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServicesOnce",
                 "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows\load",
                 "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Windows",
                 "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SharedTaskScheduler",
                 "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Windows\AppInit_DLLs")
 
                 $results = $keys | Foreach {((Get-Item $_ -ErrorAction Ignore))}

                 foreach($item in $results)
                 {                
                     if($item.property)
                     {
                 
                        $executablepath = (Get-ItemPropertyValue -ErrorAction SilentlyContinue -name $item.property -Path "Microsoft.PowerShell.Core\Registry::$($item.name)") 
                        $path = ($executablepath)
                 
                        if($path -ne 0)
                         {
                             $results += $item | Add-Member -MemberType  noteProperty -Name 'executablepath' -Value $path
                         }
                     }
                 }
                 
                 return $results         
         }
         
        catch{<#add error catch messages here... on my to do list#>}    
        }
 
     $results = (Invoke-Command -ComputerName $thing -ScriptBlock $command)
     #somehow here or below in the $datasets I am trying to add in the actual path in the registry.
 
     $DataSets+= @(
     Foreach ($result in $results)
     {
         foreach($app in $result.executablepath)
         {
         
             New-Object PSObject -Property @{
             ComputerName=$thing;
            'AutoRun Application'= ((($app -replace '\"\s.+$') -replace '^(.*[\\\/])') -replace '\.exe+') -replace '"+'
             Path = $app  
         
             }
         }
     }
     )
 }
$DataSets | Export-Csv $OutputPath -NoTypeInformation
}