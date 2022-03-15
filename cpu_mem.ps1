Import-Module -Name:"WebAdministration"
$Logfile = "$PSScriptRoot\cpu_mem_log\recycle.$((get-date).ToString("yyyy-MM-dd")).log"
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
   Write-Host $logstring
}

#上次cpu时间，processid为key，cpu时间为value
$last_process_properties = New-Object 'System.Collections.Generic.Dictionary[[int],[double]]';
#开始时间
$last_time = [System.DateTime]::Now
#获取cpu总核心数
$cpuinfo = get-wmiobject win32_processor 
$processor_count = @($cpuinfo).Count * $cpuinfo.NumberOfLogicalProcessors
$path = Split-Path -Parent $MyInvocation.MyCommand.Definition


$counter = New-Object 'System.Collections.Generic.Dictionary[[int],[int]]';

$counters = New-Object -TypeName System.Diagnostics.PerformanceCounter
$counters.CategoryName="ASP.NET"
$counters.CounterName="Requests Queued"
$counters.InstanceName=""
$hostname = ((Get-WmiObject -Class Win32_ComputerSystem).Name)
while($true){
    $now = [System.DateTime]::Now
    Get-Process -Name:"w3wp" -IncludeUserName | foreach {

        $p = $_

        if (-not $last_process_properties.ContainsKey($p.Id)) {
            $last_process_properties.Add($p.Id,$p.TotalProcessorTime.TotalSeconds)
        }else{            
            $cpuOffset = $p.TotalProcessorTime.TotalSeconds - $last_process_properties.Item($p.Id)
            $last_process_properties[$p.Id] = $p.TotalProcessorTime.TotalSeconds
            $cpu = [int](($cpuOffset/($now -$last_time).TotalSeconds/$processor_count*100))
            
            if(-not $counter.ContainsKey($p.Id)){
                $counter.Add($p.Id,0)
            }

            # 大于多少进行计数
            if($cpu -gt 90){
                $counter[$p.Id] = $counter[$p.Id]+1
                # Write-Host $p.Id "次数:" $counter[$p.Id] -ForegroundColor Red
                LogWrite ("{0} {1} {2}{3}" -f $p.Id,$p.UserName,"告警次数:",$counter[$p.Id])
            }else{
                $counter[$p.Id] = 0
            }

            # 达到计数次数就触发回收
            if($counter[$p.Id] -gt 60){
                LogWrite ("{0} {1} {2}{3}" -f $p.Id,$p.UserName,"触发回收，告警次数:",$counter[$p.Id])
                Restart-WebAppPool $p.UserName.Replace("IIS APPPOOL\","")
                $counter[$p.Id] = 0
                LogWrite ("{0} {1} {2}{3}" -f $p.Id,$p.UserName,"回收完成，告警次数置零:",$counter[$p.Id])
            }

            $line = [PSCustomObject]@{
                Time = $now.ToString("yyyy/MM/dd HH:mm:ss")
                HostName = $hostname
                AppName = $p.UserName
                CPU = $cpu
                Memory = [int]($p.PrivateMemorySize /1024/1024)
                ThreadCount = $p.Threads.Count
                ASPNETRequestsQueued = $counters.NextValue()
            }
            $line | ConvertTo-Json -Compress | Out-File -Append -FilePath "$PSScriptRoot\cpu_mem_log\cpu_mem_useage.$((get-date).ToString("yyyy-MM-dd-HH")).log" -Encoding:UTF8
        }
    }
    $last_time = $now
    Start-Sleep 1
}