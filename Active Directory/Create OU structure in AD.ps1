$fqdn = Get-ADDomain
$fulldomain = $fqdn.DNSRoot
$domain = $fulldomain.split(".")
$Dom = $domain[0]
$Ext = $domain[1]
$Sites = ("subdivision1","subdivision2","subdivision3")
$Services = ("Users","Admins","Computers","Servers","Contacts")
$FirstOU ="Main department"
New-ADOrganizationalUnit -Name $FirstOU -Description $FirstOU -Path "DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
foreach ($S in $Sites)
{
New-ADOrganizationalUnit -Name $S -Description "$S" -Path "OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
foreach ($Serv in $Services)
{
New-ADOrganizationalUnit -Name $Serv -Description "$S $Serv" -Path "OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
}
}