<#
  Set-BacktalkModel.ps1 - write which brain the voice uses into backtalk.json.
  Called by the Talk launchers on every launch. Changes only "model",
  "deep_model" and "agent_dir"; every other setting you chose is kept.
#>
param(
    [Parameter(Mandatory)] [string]$Model,
    [Parameter(Mandatory)] [string]$DeepModel,
    [Parameter(Mandatory)] [string]$AgentDir
)
$ErrorActionPreference = 'Stop'
$evieHome = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$cfg = Join-Path $evieHome 'backtalk\backtalk.json'
if (-not (Test-Path $cfg)) {
    $example = Join-Path (Split-Path $PSScriptRoot -Parent) 'config\backtalk.json.example'
    Copy-Item $example $cfg
}
$j = Get-Content $cfg -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($pair in @(@('model', $Model), @('deep_model', $DeepModel), @('agent_dir', $AgentDir))) {
    if ($j.PSObject.Properties.Name -contains $pair[0]) { $j.($pair[0]) = $pair[1] }
    else { $j | Add-Member -NotePropertyName $pair[0] -NotePropertyValue $pair[1] }
}
# Write UTF-8 WITHOUT a byte-order mark: Python's json loader rejects a BOM.
$text = $j | ConvertTo-Json -Depth 10
[IO.File]::WriteAllText($cfg, $text, (New-Object Text.UTF8Encoding $false))
Write-Host "  voice brain: $Model"
