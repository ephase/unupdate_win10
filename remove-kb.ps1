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
        "KB2953664"
)
$sheduledTasks=(
    @{name = "launchtrayprocess"; directory = "\Microsoft\Windows\Setup\GWX"},
    @{name = "refreshgwxconfig"; directory = "\Microsoft\Windows\Setup\GWX"},
    @{name = "refreshgwxconfigandcontent"; directory = "\Microsoft\Windows\Setup\GWX"},
    @{name = "regreshgwxcontent"; directory = "\Microsoft\Windows\Setup\GWX"}
)

function remove_tasks () {
    param($taskList)
    Foreach ($task in $taskList){
        Write-Host -ForegroundColor white -NoNewline "Remove Task " $task.name
        if ($PSVersionTable.PSVersion.Major -gt 2) {
            if (Get-ScheduledTask -TaskName $task.name -ErrorAction SilentlyContinue) {
                Write-Host -NoNewline -ForegroundColor DarkGreen " found! "
                Write-Host -Nonewline -ForegroundColor white "removing ... "
                Try {Unregister-ScheduledTask -TaskName $task.name -ErrorAction SilentlyContinue -Confirm:$false}
                Catch {
                    Write-Host -Nonewline -ForegroundColor white " Error "
                }
                Write-Host -ForegroundColor Green " Done"
            }
            else { Write-Host -ForegroundColor Yellow " Already removed"}
        }
        else {
            $currentTask =  $task.directory + "\" + $task.name
            if(schtasks /Query /TN $currentTask 2>$null) {
                Write-Host -NoNewline -ForegroundColor DarkGreen " found! "
                Write-Host -Nonewline -ForegroundColor white "removing ... "
                try{
                    echo $yes | schtasks /Delete /TN $currentTask /F 2>$null
                }
                Catch {
                    Write-Host -Nonewline -ForegroundColor white " Error "
                }
                Write-Host -ForegroundColor green "Done"

            }
            else { Write-Host -ForegroundColor Yellow " Already removed"}
        }
    }
}

function hide_update() {
    param($kbList)
    $session = New-Object -ComObject "Microsoft.Update.Session"
    $searcher = $session.CreateUpdateSearcher()
    $searcher.Online = $false
    $criteria = "IsInstalled=0"
    $result = $searcher.Search($criteria)
    Foreach ($kb in $kbList){
        Write-Host -NoNewline -ForegroundColor White "Hide $kb : "
        $id = $kb.Replace("KB","")
        $found = 0
        Foreach ($update in $result.Updates)  {
            if ($update.KBArticleIDs -match $id) {
                $found = 1
                if (!$update.IsHidden) {
                    $update.IsHidden = "True"
                    Write-Host -ForegroundColor green "Hidden"
                }
                else {
                    Write-Host -ForegroundColor Yellow "Already hidden"
                }
            }
        }
        if (!$found){ Write-Host -ForegroundColor Red "Not found"}
    }
}
if (stop-process -name GWX -Force -ErrorAction SilentlyContinue) {
    Write-Host "GWX process stopped ..."
}

Foreach($kbID in $kbIDs){
    $kbNum = $kbID.Replace("KB","")
    Write-Host -NoNewline -ForegroundColor white "Uninstalling $kbID : "
    if (Get-HotFix -Id $kbID -ErrorAction SilentlyContinue){
        Write-Host -NoNewline -ForegroundColor DarkGreen "found! " 
        Write-Host -Nonewline -ForegroundColor white "removing ... "
        wusa.exe /uninstall /KB:$kbNum  /norestart /quiet
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
}
Write-Host "`nHiding Updates"
Write-Host "--------------`n"

#hide_update $kbIDs
remove_tasks $sheduledTasks
