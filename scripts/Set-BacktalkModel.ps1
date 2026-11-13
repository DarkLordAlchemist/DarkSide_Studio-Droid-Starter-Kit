<#
  Set-BacktalkModel.ps1 - write which brain the voice uses into backtalk.json.
  Called by the Talk launchers on every launch. Changes "model", "deep_model"
  and "agent_dir"; every other setting you chose is kept.

  -PermissionMode (Local only): the Local lane runs voice with bypassPermissions
  (a local model + spoken yes-prompts turned one note into six prompts and ate
  "goodbye EVIE"). Before switching, YOUR own setting is saved under
  "permission_mode_paid"; the next Paid launch puts it back and removes that key.
  So the Paid voice always runs with the permission mode you chose.
#>
param(
    [Parameter(Mandatory)] [string]$Model,
    [Parameter(Mandatory)] [string]$DeepModel,
    [Parameter(Mandatory)] [string]$AgentDir,
    [string]$PermissionMode = ''
)
$ErrorActionPreference = 'Stop'
$evieHome = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$cfg = Join-Path $evieHome 'backtalk\backtalk.json'
if (-not (Test-Path $cfg)) {
    $example = Join-Path (Split-Path $PSScriptRoot -Parent) 'config\backtalk.json.example'
    Copy-Item $example $cfg
}
$j = Get-Content $cfg -Raw -Encoding UTF8 | ConvertFrom-Json
function SetKey($name, $value) {
    if ($j.PSObject.Properties.Name -contains $name) { $j.$name = $value }
    else { $j | Add-Member -NotePropertyName $name -NotePropertyValue $value }
}
$names = $j.PSObject.Properties.Name
if ($PermissionMode) {
    # Local: remember the person's own choice once, then switch.
    if (-not ($names -contains 'permission_mode_paid')) {
        $mine = if ($names -contains 'permission_mode') { $j.permission_mode } else { 'ask' }
        SetKey 'permission_mode_paid' $mine
    }
    SetKey 'permission_mode' $PermissionMode
} elseif ($names -contains 'permission_mode_paid') {
    # Paid: put the person's own choice back.
    SetKey 'permission_mode' $j.permission_mode_paid
    $j.PSObject.Properties.Remove('permission_mode_paid')
}
SetKey 'model' $Model
SetKey 'deep_model' $DeepModel
SetKey 'agent_dir' $AgentDir
# Write UTF-8 WITHOUT a byte-order mark: Python's json loader rejects a BOM.
$text = $j | ConvertTo-Json -Depth 10
[IO.File]::WriteAllText($cfg, $text, (New-Object Text.UTF8Encoding $false))
Write-Host "  voice brain: $Model   (permission mode: $($j.permission_mode))"
