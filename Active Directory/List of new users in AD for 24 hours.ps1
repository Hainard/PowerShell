$lastday = ((Get-Date).AddDays(-1))
$filename = Get-Date -Format yyyy.MM.dd
$exportcsv=”c:\ps\new_ad_users_” + $filename + “.csv”
Get-ADUser -filter {(whencreated -ge $lastday)} –properties whencreated | Select-Object Name, UserPrincipalName, SamAccountName, whencreated | Export-csv -path $exportcsv