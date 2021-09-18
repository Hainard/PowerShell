$a = (Get-Host).UI.RawUI
$a.WindowTitle = "Sync Folder To Ftp"
     
$ftp = "ftp://FTP_server_address/"
$localDirectory = "C:\Backup"
$user = "Username"
$pass = "Password"
     
$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)

$Files = Get-ChildItem $localDirectory | Where {$_.LastWriteTime -gt (Get-Date).AddDays(-1)} 
foreach ($File in $Files)
    {
        $LocalFile = $File.FullName

        Write-Host "Getting $File from $localDirectory" -Foreground "Red"

        $webclient.UploadFile($ftp + $File, $LocalFile) 

        Write-Host "Puting $File to $ftp" -Foreground "Yellow"
    } 
     
Write-Host "Finished Sync to $ftp" -Foreground "Green"
