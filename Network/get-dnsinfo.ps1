
#Get Dns information from NIC. Input is a list of computer names. This uses WMIC to gather the info.
$computers = Get-Content c:\computername.txt

$finallist = @()

ForEach ($computer in $computers) {
    $Networks = Get-WMIObject Win32_NetworkAdapterConfiguration `
        -Filter IPEnabled=TRUE `
        -ComputerName $Computer `
    
    Foreach ($network in $networks) {
        
        $DNSServers = $Network.DNSServerSearchOrder
        $NetworkName = $Network.Description
        
        If (!$DNSServers) {
            $PrimaryDNSServer = "Notset"
            $SecondaryDNSServer = "Notset"
        }
        
        elseif ($DNSServers.count -eq 1) {
            $PrimaryDNSServer = $DNSServers[0]
            $SecondaryDNSServer = "Notset"
        }
        
        else {
            $PrimaryDNSServer = $DNSServers[0]
            $SecondaryDNSServer = $DNSServers[1]
        }

        $properties = [ordered] @{

            DNSHostName        = $Computer
            PrimaryDNSServer   = $PrimaryDNSServer
            SecondaryDNSServer = $SecondaryDNSServer
            NetworkName        = $NetworkName

        }
        
        $finallist += New-Object psobject -Property $properties
    } 
} 

$finallist | Export-CSV -path servers.csv -NoTypeInformation
