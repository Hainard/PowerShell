$Sender = "youremail@gmail.com"
$Subject = 'Внимание! Скоро истекает срок действия Вашего пароля!'
$BodyTxt1 = 'Срок действия Вашего пароля для'
$BodyTxt2 = 'заканчивается через '
$BodyTxt3 = 'дней. Не забудьте заранее сменить Ваш пароль. Если у вас есть вопросы, обратитесь в службу HelpDesk.'
$smtpserver ="smtp.domain.com"
$warnDays = (get-date).adddays(7)
$2Day = get-date
$Users = Get-ADUser -SearchBase 'OU=Users,DC=corp,DC=winitpro,DC=ru' -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties msDS-UserPasswordExpiryTimeComputed, EmailAddress, Name | select Name, @{Name ="ExpirationDate";Expression= {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, EmailAddress
foreach ($user in $users) {
if (($user.ExpirationDate -lt $warnDays) -and ($2Day -lt $user.ExpirationDate) ) {
$lastdays = ( $user.ExpirationDate -$2Day).days
$EmailBody = $BodyTxt1, $user.name, $BodyTxt2, $lastdays, $BodyTxt3 -join ' '
$encoding = [System.Text.Encoding]::UTF8
Send-MailMessage -To $user.EmailAddress -From $Sender -SmtpServer $smtpserver -Subject $Subject -Body $EmailBody -Encoding $encoding
}
}