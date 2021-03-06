﻿$count = 0 #simple counter for number of tests 
While($count -le 25){
    $count++
    $seed = @("starwars","topgun","flavortown")[(Get-Random -maximum 3)]; 
    $dockerstat = (docker inspect $(imageName) | ConvertFrom-Json)
    $quote = (Invoke-RestMethod -Method GET -Uri "http://localhost:8000/$seed").body.table.tr.th.'#text' 
    $time = New-TimeSpan -Start ([datetime]$dockerstat.State.StartedAt) -End (get-date)
    $timestr = if($time.hours -lt 1){
        "$([math]::Round($time.TotalMinutes,1)) Minutes"
    }else{
        "$([math]::Round($time.TotalHours,1)) Hours"
    }
    "$count seed: $seed | docker: up $timestr | $quote"
    Start-Sleep -Milliseconds 500
}
