$Logfile = "$PSScriptRoot\iis_current_request\iis_current_request.$((get-date).ToString("yyyy-MM-dd-HH")).log"

$hostname = ((Get-WmiObject -Class Win32_ComputerSystem).Name)
Get-Process -Name:"w3wp" -IncludeUserName | foreach {
    $p = $_
    $CurrentRequests = (Get-WebRequest -Process $p.Id | Measure-Object -Property timeElapsed  -Average -Maximum)
    $line = [PSCustomObject]@{
        Time = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
        HostName = $hostname
        AppName = $p.UserName
        CurrentRequestsCount = $CurrentRequests.Count
        CurrentRequestsTimeElapsedAverage = $CurrentRequests.Average
        CurrentRequestsTimeElapsedMaximum = $CurrentRequests.Maximum
    }
    $line | ConvertTo-Json -Compress | Out-File  -Append -FilePath $Logfile -Encoding:UTF8
}