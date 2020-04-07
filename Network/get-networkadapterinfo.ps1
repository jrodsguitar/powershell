##How to return only the IPv4 address from a remote computer##

##In this example we use Windows Management Instrumentation infrastructure, to connect to a remote PC, and retrieves network information from the enabled NIC##

##Description of each step is in the inline comments of the script below##

#-
#Computer to connect to
$computer = 'server123'

#Utilize the WMI Win32_NetworkAdapterConfiguration class to return network adapter configuration. We filter on 'ipenabled'.
$networkAdapterInfo = (Get-WmiObject -CN $computer -Class Win32_NetworkAdapterConfiguration  -Filter 'ipenabled = "true"')
    
#This filters out the IPv6 address by using a regex pattern then replaces the 'ipaddress' field from our existing $networkAdapterInfo object with the IPv4 address
$networkAdapterInfo.ipaddress = $networkAdapterInfo.IPAddress.ForEach({($_ | select-string -pattern "(\d{1,3}(\.?)){4}")})
    
#Return the information we just gathered
$networkAdapterInfo
#-

##Sample Output:##