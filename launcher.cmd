@echo off
cd /d "%~dp0"
REM CMD execution script for remove-kb.ps1
echo Change ps execution policy ...
powershell set-executionpolicy unrestricted

echo .
echo Launch remove-kb script ...
powershell "%~dp0remove-kb.ps1"

echo Restore ps execution policy ...
powershell set-executionpolicy restricted
PAUSE
