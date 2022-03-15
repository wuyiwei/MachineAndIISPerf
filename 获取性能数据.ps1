Get-WmiObject win32_OperatingSystem |%{"Total Physical Memory: {0}KB`nFree Physical Memory : {1}KB`nTotal Virtual Memory : {2}KB`nFree Virtual Memory  : {3}KB" -f $_.totalvisiblememorysize, $_.freephysicalmemory, $_.totalvirtualmemorysize, $_.freevirtualmemory}

Get-WmiObject win32_OperatingSystem | Get-Member 

#计数器可通过将监视器的设置存为HTML然后打开取得

(Get-Counter -Counter "\Processor Information(_Total)\% Processor Time").CounterSamples | Select-Object -ExpandProperty CookedValue

(Get-Counter -Counter "\Memory\Committed Bytes").CounterSamples | Select-Object -ExpandProperty CookedValue

(Get-Counter -Counter "\Processor Information(_Total)\% Processor Time").CounterSamples | Select-Object -ExcludeProperty CookedValue



C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -OutputFormat "Text" -Command "& {(Get-Counter -Counter '\Processor(_Total)\% Processor Time').CounterSamples | Select-Object -ExpandProperty CookedValue}"


# 获取指定程序的CPU利用率
(Get-Counter "\Process(LogPushTaskPort*)\% Processor Time").CounterSamples | Select-Object -ExpandProperty CookedValue

((Get-Counter "\Process(LogPushTaskPort*)\% Processor Time").CounterSamples | Measure-Object CookedValue -Sum).Sum

((Get-Counter "\Process(Auditor*)\% Processor Time").CounterSamples | Measure-Object CookedValue -Sum).Sum

((Get-Counter "\Process(EShopToolService*)\% Processor Time").CounterSamples | Measure-Object CookedValue -Sum).Sum

#获取所有的计数器path
(Get-Counter -ListSet *).Paths | Out-File c:\test.txt -width 120


while($true)
{
    $value =  (Get-Counter  "\ASP.NET\Requests Queued").CounterSamples | Select-Object -ExpandProperty CookedValue
    
    Start-Sleep 1000;
}

(Get-Counter  "\Web Service(*)\Current Connections").CounterSamples