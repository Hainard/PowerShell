<#
смотрит за спулером, чистит очередь и перегружает службу
дополнение отправка уведомления на почту
#>
$StyleYellowSimple = @'
<style>
body { background-color:#ffffff;
       font-family:Tahoma;
       font-size:12pt; }
td, th { border:1px solid black;
         border-collapse:collapse; }
th { color:white;
     background-color:black; }
     table, tr, td, th { padding: 2px; margin: 0px }
table { font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
        font-size: 14px;
        border-radius: 10px;
        border-spacing: 0;
        text-align: center; }
th { background: #BCEBDD;
     color: white;
     text-shadow: 0 1px 1px #2D2020;
     padding: 10px 20px; }
th, td { border-style: solid;
         border-width: 0 1px 1px 0;
         border-color: white; }
th:first-child, td:first-child { text-align: left; }
th:first-child { border-top-left-radius: 10px; }
th:last-child { border-top-right-radius: 10px;
                border-right: none; }
td { padding: 10px 20px;
     background: #F8E391; }
tr:last-child td:first-child { border-radius: 0 0 0 10px; }
tr:last-child td:last-child { border-radius: 0 0 10px 0; }
tr td:last-child { border-right: none; }
</style>
'@

<#
    отправляет письмо на указанный адрес с оповещением.
    для использования в других частях скриптов
#>
function Send-ToAdmin
{
Param ( [string]$MailAddress = 'admin@domain.ru',
        [string]$Subject = 'Test message',
        [string]$Header1,
        [string]$Body,
        [string]$Style
    )
BEGIN {}
PROCESS {
    
    Write-Verbose 'definiting CSS'

<#    Switch ($Style)
    {
        'YellowSimple' { $head = $StyleYellowSimple; break }
        'BlueSimple' { $head = $StyleBlueSimple; break }
        'DataTable' {$head = $StyleResposTable; break }
        default { $head = $StyleYellowSimple; break }
    }#>
    $head = $StyleYellowSimple
    $encoding = [System.Text.Encoding]::UTF8
    
    $Date = Get-Date
    $MailBody = ConvertTo-HTML -head $head -PostContent $Body -PreContent "<h1>$Subject. Date:$Date</h1><br><h3>$Header1</h3>" | Out-String
    
    Write-Verbose "Sending e-mail. Address: $MailAddress"

    $params = @{'To'=$MailAddress
               'From'='bot@domain.local'
               'Subject'="$Subject $Date"
               'Body'=$MailBody
               'BodyAsHTML'=$True
               'SMTPServer'='Exchange.domain.ru'
               }

    Send-MailMessage @params -Encoding $encoding
}
END{}
}

$cfi = 0
for( $i=1; $i -le 5; $i++ ) {
    Start-Sleep -Seconds 1
    $load = Get-WmiObject win32_Processor | select -Property LoadPercentage

    Write-Host "CPU load $load" -ForegroundColor Green

    if ($($load.LoadPercentage) -gt 95) { 
        $cfi = $cfi + 1
        Write-Host "indicator is $cfi" -ForegroundColor Green
    }
}

if ($cfi -gt 2) {
    # дергаем процессы для инфо
    $temp = Get-Process | sort -Property cpu -Descending

    $proc = @()
    foreach ( $p in $temp ) {
        $props = [ordered]@{    Name=$p.ProcessName
                                CPU_total_in_seconds=$p.CPU
                                PhysicallMemory_in_Mb=$p.WS/1mb
                                ProcessID=$p.Id                                                           
                        }

        $obj = New-Object -TypeName PSObject -Property $props
 
        $proc += $obj
    }

    $temp = Get-Printer | Get-PrintJob
    
    $Jobs = @()
    foreach ( $p in $temp ) {
        $props = [ordered]@{    ID = $p.Id
                                PrinterName=$p.PrinterName
                                UserName=$p.UserName
                                DocumentName=$p.DocumentName
                                DataType=$p.Datatype
                                SubmittedTime=$p.SubmittedTime
                                Size=$p.Size
                                JobTime=$p.JobTime
                                PagesPrinted=$p.PagesPrinted
                                TotalPages=$p.TotalPages
                                Status=$p.Status
                        }

        $obj = New-Object -TypeName PSObject -Property $props
 
        $Jobs += $obj
    }

    # перегружаем спулер тут
    Write-Host "Перегружаем спулер" -ForegroundColor Green
     
    Get-Service *spool* | Stop-Service -Force -Verbose
    Start-Sleep -Seconds 5
    $path = "C:\Windows\System32\spool\PRINTERS\"
    Get-ChildItem $path -File | Remove-Item -Force -Verbose
    Get-Service Spooler | Start-Service -Verbose

    $frag1 = $proc | ConvertTo-Html -As table -Fragment -PreContent '<h2>Процессы в памяти перед перезагрузкой спулера</h2>' | Out-String
    $frag2 = $Jobs | ConvertTo-Html -As table -Fragment -PreContent '<h2>Задания печати из всех очередей всех принтеров</h2><br>если есть список то скорее всего задание зависло (принтер отключен)' | Out-String

    $Body = '<br><br>служба сервера была перезагружена т.к. процессор был слишком сильно нагружен<br><br>'
    $Body = $Body + $frag2 + '<br><br>'
    $Body = $Body + $frag1 + '<br><br>---------------------------------------------------------------------------<br>дополнительная отладочная информация<br><H2>список загруженных библиотек в памяти на момент зависания по каждому процессу</H2>'

    $Date = Get-Date 
    $header = "$Date сервер печати"

    $Style = 'YellowSimple'
    Send-ToAdmin -MailAddress 'admin@domain.ru' -Style $Style -Subject 'Сервер печати - процессор загружен на 100%' -Body $Body -Header1 $header
}