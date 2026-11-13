<#
  Make-Shortcuts.ps1
  Puts the four EVIE launchers on the Desktop.
  Run once at the end of setup. Safe to run again - it overwrites only its own
  shortcuts and touches nothing else.

  -InFolder   put them in a Desktop folder called "EVIE" instead of loose on the Desktop
#>

param([switch]$InFolder)

$ErrorActionPreference = 'Stop'
$scripts = $PSScriptRoot
$target  = [Environment]::GetFolderPath('Desktop')

if ($InFolder) {
    $target = Join-Path $target 'EVIE'
    if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target | Out-Null }
}

$shell = New-Object -ComObject WScript.Shell

# Icon choice is cosmetic. Paid shortcuts get the network globe, local ones get
# the computer, so the two are distinguishable at a glance without reading.
$launchers = @(
    @{ Name = 'EVIE - Chat (Paid)';  File = 'EVIE-Chat-Paid.bat';  Icon = 18
       Desc = 'Type to EVIE on Claude (your subscription). Needs internet. Use this for anything hard.' }
    @{ Name = 'EVIE - Talk (Paid)';  File = 'EVIE-Talk-Paid.bat';  Icon = 18
       Desc = 'Talk to EVIE on Claude. Hold the key, speak, let go.' }
    @{ Name = 'EVIE - Chat (Local)'; File = 'EVIE-Chat-Local.bat'; Icon = 15
       Desc = 'Type to EVIE on gpt-oss-20b, on this machine. No internet, no sign-in.' }
    @{ Name = 'EVIE - Talk (Local)'; File = 'EVIE-Talk-Local.bat'; Icon = 15
       Desc = 'Talk to EVIE fully offline on gpt-oss-20b. Everything runs on this laptop.' }
)

foreach ($l in $launchers) {
    $bat = Join-Path $scripts $l.File
    if (-not (Test-Path $bat)) { Write-Warning "Missing: $bat - skipped."; continue }

    $lnk = Join-Path $target "$($l.Name).lnk"
    $sc = $shell.CreateShortcut($lnk)
    $sc.TargetPath       = $bat
    $sc.WorkingDirectory = $scripts
    $sc.Description      = $l.Desc
    $sc.IconLocation     = "$env:SystemRoot\System32\shell32.dll,$($l.Icon)"
    $sc.Save()
    Write-Host "  Created: $($l.Name)"
}

Write-Host ''
Write-Host "Done. Four shortcuts in: $target"
Write-Host 'Paid = smarter, needs internet and your subscription.  Local = offline gpt-oss, never asks you to sign in.'
