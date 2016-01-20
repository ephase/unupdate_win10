$kbIDs=("KB3075249", #telemetry for Win7/8.1
        "KB3080149", #telemetry for Win7/8.1
        "KB3021917", #telemetry for Win7
        "KB3022345", #telemetry
        "KB3068708", #telemetry
        "KB3044374", #Get Windows 10 for Win8.1
        "KB3035583", #Get Windows 10 for Win7sp1/8.1
        "KB2990214", #Get Windows 10 for Win7 without sp1
        "KB2952664", #Get Windows 10 assistant
        "KB2976978",
        "KB2876229",
        "kb2953664"
)


function hide_update() {
    param($kb)
    $i = 0
    $found = 0
    Write-Host -NoNewline -ForegroundColor White "Hide $kb : "
    $session = New-Object -ComObject "Microsoft.Update.Session"
    $searcher = $session.CreateUpdateSearcher()
    $searcher.Online = $false
    $criteria = "IsInstalled = 0"
    $result = $searcher.Search($criteria)
    Foreach ($update in $result.Updates)  {
        $found = 0
        $kb | Foreach {
            if ($update.KBArticleIDs -match $_) {
                if (!$updates.Item($i).IsHidden) {
                    $update($i).IsHidden = "True"
                    Write-Host -ForegroundColor green "Hidden"
                    $found = 1
                }
                else {
                Write-Host -ForegroundColor Yellow "Already hidden"
                }
            }
        }
    }
    if (!$found){ Write-Host -ForegroundColor Red "Not found"}
}

Foreach($kbID in $kbIDs){
    $kbNum = $kbID.Replace("KB","")
    Write-Host -NoNewline -ForegroundColor white "Uninstalling $kbID : "
    if (Get-HotFix -Id $kbID -ErrorAction SilentlyContinue){
        Write-Host -NoNewline -ForegroundColor DarkGreen "found! " 
        Write-Host -Nonewline -ForegroundColor white "removing ... "
        wusa.exe /uninstall /KB:$kbNum  /norestart /quiet /log:wsua.log
        Do
	    {
    		Start-Sleep -Seconds 3
    	}while(Invoke-Command -ScriptBlock {Get-Process  | Where-Object {$_.name -eq "wusa"}})
        if(Get-HotFix -Id $kbID -ErrorAction SilentlyContinue){
		    Write-Host -ForegroundColor Red "Failed"
	    }
	    else{
		    Write-Host -ForegroundColor Green "Done"
	    }
    }
    else {
        Write-Host -ForegroundColor Yellow ("Not installed")
    }
    hide_update $kbNum 
}
