#Jose Rodriguez
#3/21/2020

#How does one find the Property names that are returned by get-winevent?
#This is a sample of how to query and find the property names.

#Generate query sampel data. Uses a live Security log event.

$events = (Get-WinEvent -FilterHashtable @{LogName = 'Security'; ID = 4624 })[0] 

#Query Windows to retrieve the json template that our event property names will come from:
#https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/how-to-list-xml-elements-in-eventdata

$version = $events.version
$secEvents = (get-winevent -listprovider "microsoft-windows-security-auditing").Events.Where( { $_.id -eq 4624 -and $_.version -eq $version })

#Put it all together
#This outputs the PropertyName, ExamplePropertyValue from the live query above, and the default Index number of each property value (if not sorted) of "(Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624})[0]).properties"

Write-output "PropertyName  ExamplePropertyValue   IndexNumber"
$properties = ($secEvents.description -split '\s\s\s' -match ':')
for ($i = 0; $i -le $properties.length - 1; $i++) {
    
    if (($properties[$i] -notmatch '%')) {
    
        $properties[$i]
      
    }

    if (($properties[$i] -match '%')) {
         
        $cap = ($properties[$i] | select-string '\%(.*)').Matches.Groups[1].Value
        $arrayindex = $cap - 1     
        $propertyname = ((($properties[$i])).Substring(0, $properties[$i].IndexOf(':')))
        $eventvalue = $($events.Properties[$arrayindex].value)
      
        ("$propertyname `: $eventvalue `: $arrayindex").TrimStart()
    }

}

#Example snippet
#for($i=0;$i-le $properties.length-1;$i++)
#{“`$array[{0}] = {1}” -f $i,$properties[$i]}