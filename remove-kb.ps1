$kbIDs=(
        "KB2902907",
        "KB2953664",
		"KB2976978", #telemetry for Win8/8.1
        "KB2990214", #Get Windows 10 for Win7 without sp1
        "KB2952664", #Get Windows 10 assistant
		"KB3012973", #Windows 10 suggested (Forced?) update
		"KB3021917", #telemetry for Win7
        "KB3022345", #telemetry
		"KB3035583", #Get Windows 10 for Win7sp1/8.1
        "KB3044374", #Get Windows 10 for Win8.1
		"KB3050265", #Update for Windows Update on Win7
        "KB3065987", #Update for Windows Update on Win7/Server 2008R2
		"KB3068708", #telemetry
		"KB3075249", #telemetry for Win7/8.1
		"KB3075851", #Update for Windows Update on Win7
        "KB3075853", #Update on Win8.1/Server 2012R2
        "KB3080149", #telemetry for Win7/8.1
		"KB3081437", #Windows 10 compatibility update
		"KB3081454", #Windows 10 compatibility update
		"KB3083324", #Windows 7 to Windows 10 preparation update
		"KB3083325", #Windows 8 to Windows 10 preparation update
		"KB3150513", #Windows 10 compatibility modile for Win7/Win8 (may 2016)
		"KB3112336", #Windows 8.1 > Windows 10
		"KB3112343"  #Windows 7 - 8.1 > Windows 10
)

$sheduledTasks=(
    @{name = "launchtrayprocess"; directory = "\Microsoft\Windows\Setup\GWX"},
    @{name = "refreshgwxconfig"; directory = "\Microsoft\Windows\Setup\GWX"},
    @{name = "refreshgwxconfigandcontent"; directory = "\Microsoft\Windows\Setup\GWX"},
    @{name = "refreshgwxcontent"; directory = "\Microsoft\Windows\Setup\GWX"}
)

$gwx_dirs=(
    "$env:windir\system32\GWX",
    "$env:windir\SysWOW64\GWX"
)

# You need to modify this variable whith administrator group name
# Here for French Windows this is Administrateurs
$adminGroup="Administrateurs"
$yes="O"

function add_reg_object {
    param (
        $reg_path,
        $reg_name,
        $reg_value
    )
    if (!(Test-Path $reg_path)){
        Write-Host -nonewline "creating $reg_path ..."
        New-Item -Path $reg_path -Force
    }
    if ($reg_name -and $reg_value){
        Write-Host "Reg key $reg_name created with value $reg_value"
        New-ItemProperty -Path $reg_path -Name $reg_name -Value $reg_value -Force      
    }
    else {
        Write-Host "[ERROR] add_reg_value : no `$reg_name or `$reg_value parameters..."
    }   
}

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
            else { Write-Host -ForegroundColor Yellow " Already removed" }
        }
    }
}

function hide_update() {
    param($kbList)
    $session = New-Object -ComObject "Microsoft.Update.Session"
    $searcher = $session.CreateUpdateSearcher()
    #$searcher.Online = $false
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
        if (!$found){ Write-Host -ForegroundColor Red "Not found" }
    }
}
#Remove GWX Files (test)
function lock_dir {
    param([string]$dir)
    Write-Host -ForegroundColor white "removing $dir content ... "
    takeown /F "$dir" /R /D $yes 2>&1 | Out-Null
    icacls "$dir" /C /grant $adminGroup":F" /T 2>&1 | Out-Null
    Try{ Remove-Item $dir\* -Force -Recurse -ErrorAction SilentlyContinue}
    Catch {Write-Host -ForegroundColor Red "Some files can't be deleted."}
    #lock GWX directory
    icacls "$dir" /deny *S-1-1-0:`(CI`)`(OI`)F 2>&1 | Out-Null
 }

Write-Host -Nonewline -ForegroundColor white "Searching for GWX process ... "
if (Get-Process -name GWX -ErrorAction SilentlyContinue) {
    Write-Host -ForegroundColor DarkGreen -NoNewLine "Running "
    Write-Host -ForegroundColor white "removing ... "
    Try {Stop-Process -name GWX -Force -ErrorAction SilentlyContinue}
    Catch { Write-Host -ForegroundColor Red "Error"}
}
else { Write-Host -ForegroundColor Yellow ("Not running")}

Write-Host -ForegroundColor white "`nRemoving and locking GWX folders ... "
$gwx_dirs | ForEach {
    lock_dir $_
}

Write-Host -ForegroundColor white "`nRemoving Updates... "

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

Write-Host -ForegroundColor white "`nHidding Updates... "
hide_update $kbIDs

Write-Host -ForegroundColor white "`nRemoving sheduled tasks ... "
remove_tasks $sheduledTasks

Write-Host -ForegroundColor white "`nReg update ... "
add_reg_object "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" "AllowOSUpgrade" "0"
