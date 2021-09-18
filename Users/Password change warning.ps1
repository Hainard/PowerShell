Add-Type -AssemblyName PresentationFramework
$curruser= Get-ADUser -Identity $env:username -Properties 'msDS-UserPasswordExpiryTimeComputed','PasswordNeverExpires'
if ( -not $curruser.'PasswordNeverExpires') {
$timediff=(new-timespan -start (get-date) -end ([datetime]::FromFileTime($curruser."msDS-UserPasswordExpiryTimeComputed"))).Days
if ($timediff -lt 5) {
$msgBoxInput = [System.Windows.MessageBox]::Show("Ваш пароль истекает через "+ $timediff + " дней!`nХотите сменить пароль сейчас?","Внимание!","YesNo","Warning")
switch ($msgBoxInput) {
'Yes' {
cmd /c "explorer shell:::{2559a1f2-21d7-11d4-bdaf-00c04f60b9f0}"
}
'No' { }
}
}
}