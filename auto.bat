@echo off
set PS=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

:: Auto-élévation admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Demande des droits administrateur...
    "%PS%" -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0edge-removal.ps1"

pause
