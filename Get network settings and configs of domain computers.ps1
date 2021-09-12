# requesting credential from the domain admin
$cred = Get-Credential
$Clients = Get-ADComputer -Filter * | Sort-Object name | Select-Object name
$CompData = @()

foreach ($cli in $Clients)    {
    if (( Test-Connection $cli.Name -Count 2 -Quiet ) -eq 'True')       {
        if ($cli.name -ne $env:COMPUTERNAME)        {
            #get information from WMI
            $os = Get-WmiObject -ComputerName $cli.name Win32_OperatingSystem -Credential $cred
            $net = Get-WmiObject -Class Win32_NetWorkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName $cli.name  -Credential $cred
            $nic = Get-WmiObject -Class Win32_NetWorkAdapter -ComputerName $cli.name  -Credential $cred | where {$_.adaptertype -eq 'Ethernet 802.3'} | where { $_.NetEnabled -eq 'True'}
            $disk = Get-WmiObject -Class Win32_DiskDrive -ComputerName $cli.name -Credential $cred 

            $props = [ordered]@{ Name=$os.CSName
                        OSName=$os.Caption
                        OSSN=$os.SerialNumber
                        OSVersion=$os.Version
                        OSSystemDirectory=$os.SystemDirectory
                        OSBuild=$os.BuildNumber
                        OSMUI=$os.MUILanguages
                        OSBootDevice=$os.BootDevice
                        NICNetConnectionID=$nic.NetConnectionID
                        NICName=$nic.Name
                        NICDeviceID=$nic.DeviceID
                        NICAdapterType=$nic.AdapterType
                        NICIndex=$nic.Index
                        NICInterfaceIndex=$nic.InterfaceIndex
                        NICMAC=$nic.MACAddress
                        NICManufacturer=$nic.Manufacturer
                        NICNetEnabled=$nic.NetEnabled
                        NICPhysical=$nic.PhysicalAdapter
                        NICProductName=$nic.ProductName
                        NICServiceName=$nic.ServiceName
                        NICSpeed=$nic.Speed
                        NetDHCPEnabled=$net.DHCPEnabled
                        NetIPAddress=$net.IPAddress
                        NetDefaultGateway=$net.DefaultIPGateway
                        DiskName=$disk.Caption 
                        DiskStatus=$disk.Status 
                        DiskDeviceId=$disk.deviceid 
                        DiskSerialNumber=$disk.serialnumber 
                        DiskSize=$disk.size 
                        }

            $obj = New-Object -TypeName PSObject -Property $props
            $CompData += $obj
        }
    }
}

$CompData