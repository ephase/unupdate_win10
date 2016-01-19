@echo off
cd /d "%~dp0"
REM CMD exectition script for remove-kb.ps1
echo Change ps execution policy ...
powershell set-executionpolicy unrestricted

echo .
echo Launch remove-kb script ...
powershell "%~dp0remove-kb.ps1"

echo REstore ps execution policy ...
powershell set-executionpolicy restricted
PAUSE
