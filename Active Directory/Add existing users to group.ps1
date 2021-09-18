## Имя домена AD
$ADDomain = 'dc=domain,dc=by'
## Имя динамической группы

$ADGroupname = 'Sales'
## Список OU для поиска пользователей
$ADOUs = @(
"OU=Users,OU=Accounts,OU=subdiv1,$ADDomain",
"OU=Users,OU=Accounts,OU=subdiv2,$ADDomain"
)
$users = @()
# Поиск пользователей по указанным OU
foreach($OU in $ADOUs){
$users += Get-ADUser -SearchBase $OU -Filter {Department -like "Отдел продаж"}
}
foreach($user in $users)
{
Add-ADGroupMember -Identity $ADGroupname -Member $user.samaccountname -ErrorAction SilentlyContinue
}
## Теперь проверим всех пользователей группы на соотвествие критериям выборки и, если пользователь не соотвествует (перенесен в другую OU, изменен отдел) исключить его из группы
$members = Get-ADGroupMember -Identity $ADGroupname
foreach($member in $members)
{
if($member.distinguishedname -notlike "*OU=Users,OU=Accounts,OU=subdiv1,$ADDomain*" -and $member.distinguishedname -notlike "*OU=Users,OU=Accounts,OU=subdiv2,$ADDomain*")
{
Remove-ADGroupMember -Identity $ADGroupname -Member $member.samaccountname -Confirm:$false
}
if ((Get-ADUser -identity $member -properties Department|Select-Object Department).department -notlike "Отдел продаж" )
{
Remove-ADGroupMember -Identity $ADGroupname -Member $member.samaccountname -Confirm:$false
}
}