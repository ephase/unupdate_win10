$kbIDs=("KB3035583", "KB2952664", "KB3021917", "KB2976978", "KB2876229")


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
    #$result.Updates | Foreach {
    While ((!$found) -and ($i -lt $result.Updates.Count)) {
        if ($result.Updates.Item($i).KBArticleIDs -match $kb) {
            $found = 1
            if (!$result.Updates.Item($i).IsHidden) {
                $result.Updates.Item($i).IsHidden = "True"
                Write-Host -ForegroundColor green "Hidden"
            }
            else {
                Write-Host -ForegroundColor Yellow "Already hidden"
            }
        }
        $i++
    }
    if (!$found){ Write-Host -ForegroundColor Red "Not found"}
}

Foreach($kbID in $kbIDs){
    $kbNum = $kbID.Replace("KB","")
    Write-Host -NoNewline -ForegroundColor white "Uninstalling $kbID : "
    
    if ($exist){
        Write-Host -NoNewline -ForegroundColor DarkGreen "found!" -ForegroundColor white "removing ... "
        wusa.exe /uninstall /KB:$kbNum  /norestart /quiet /log:wsua.log
        Do
	    {
    		Start-Sleep -Seconds 3
    	}while(Invoke-Command -ScriptBlock {Get-Process  | Where-Object {$_.name -eq "wusa"}})
        if(Get-HotFix -Id $kbID -ErrorAction SilentlyContinue){		
		    Write-Host -NoNewline -ForegroundColor Red "Failed"
	    }
	    else{
		    Write-Host -NoNewline -ForegroundColor Green "Done"
	    }
    }
    else {
        Write-Host -ForegroundColor Yellow ("Not installed")
    }
    hide_update $kbNum 
}
