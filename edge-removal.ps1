Write-Host "=== EDGE REMOVAL ===" -ForegroundColor Red

#Désinstallation forcée Edge
$edgePaths = @(
    "C:\Program Files (x86)\Microsoft\Edge\Application",
    "C:\Program Files\Microsoft\Edge\Application"
)

foreach ($path in $edgePaths) {
    if (Test-Path $path) {
        $ver = Get-ChildItem $path | Sort-Object Name -Descending | Select-Object -First 1
        $setup = "$path\$($ver.Name)\Installer\setup.exe"
        if (Test-Path $setup) {
            Write-Host "Suppression Edge $($ver.Name)..." -ForegroundColor Yellow
            Start-Process $setup -ArgumentList "--uninstall --system-level --force-uninstall" -Wait
        }
    }
}

#Nettoyage des fichiers restants
Write-Host "Nettoyage des dossiers..." -ForegroundColor Cyan
$folders = @(
    "C:\Program Files (x86)\Microsoft\Edge",
    "C:\Program Files\Microsoft\Edge",
    "$env:LOCALAPPDATA\Microsoft\Edge",
    "$env:LOCALAPPDATA\Microsoft\EdgeUpdate"
)

foreach ($f in $folders) {
    Remove-Item $f -Recurse -Force -ErrorAction SilentlyContinue
}

#Désactiver services Edge Update
Write-Host "Desactivation des services Edge Update..." -ForegroundColor Cyan
$services = "edgeupdate","edgeupdatem"
foreach ($s in $services) {
    Stop-Service $s -Force -ErrorAction SilentlyContinue
    Set-Service $s -StartupType Disabled -ErrorAction SilentlyContinue
}

#Supprimer tâches planifiées Edge
Write-Host "Suppression des taches planifiees..." -ForegroundColor Cyan
Get-ScheduledTask | Where-Object {$_.TaskName -like "*Edge*"} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

#Blocage via registre (policies)
Write-Host "Blocage Edge via registre..." -ForegroundColor Cyan
$regPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Edge",
    "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdgeUpdate"
)

foreach ($r in $regPaths) {
    New-Item $r -Force | Out-Null
}

Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "UpdateDefault" -Type DWord -Value 0
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "AutoUpdateCheckPeriodMinutes" -Type DWord -Value 0
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdgeUpdate" -Name "UpdateDefault" -Type DWord -Value 0

Write-Host "=== EDGE EST DEGAGE ===" -ForegroundColor Green
Write-Host "Redemarrage conseille." -ForegroundColor Yellow
Write-Host "Merci d'utiliser mon tool !" -ForegroundColor Red
Pause
