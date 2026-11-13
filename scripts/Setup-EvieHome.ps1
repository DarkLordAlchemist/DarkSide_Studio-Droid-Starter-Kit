<#
  Setup-EvieHome.ps1 - the mechanical part of setup, done the same way every time.
  Run by EVIE during SETUP.md (Phase 2), after the interview. Safe to re-run:
  it NEVER overwrites or deletes an existing file - it only fills in what is missing.

  Builds, inside %USERPROFILE%\EVIE (the folder above this kit):
    CLAUDE.md                     EVIE's boot file (from templates; interview fills it)
    Vault\                        her memory, as a Karpathy-style LLM wiki:
      VAULT-INDEX.md  (schema)    how the wiki works - the rules
      index.md        (catalog)   one line per page
      log.md          (timeline)  append-only record of every change
      raw\  outputs\              sources in / filed answers out
      GUARDRAILS.md Profile.md Active Priorities.md + the numbered folders
    .claude\settings.json         hooks: delete protection + compaction sweep
    .claude\skills\wiki\SKILL.md  the ingest / query / lint playbook
    .claude\protected-paths.txt   extra folders the delete guard protects
    Desktop shortcuts             via Make-Shortcuts.ps1

  -VaultPath <dir>   use an existing notes folder as the vault (never moved)
  -NoShortcuts       skip the Desktop shortcuts
#>
param([string]$VaultPath = '', [switch]$NoShortcuts)
$ErrorActionPreference = 'Stop'
$Kit      = Split-Path $PSScriptRoot -Parent
$EvieHome = Split-Path $Kit -Parent
$T        = Join-Path $Kit 'templates'
$Vault    = if ($VaultPath) { $VaultPath } else { Join-Path $EvieHome 'Vault' }
$created  = @(); $kept = @()

function Ensure-Dir($p) { if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null; $script:created += $p } }
function Place($src, $dst) {
    if (Test-Path $dst) { $script:kept += $dst; return }
    Ensure-Dir (Split-Path $dst -Parent)
    $text = [IO.File]::ReadAllText($src).Replace('{{EVIE_HOME}}', $EvieHome).Replace('{{VAULT}}', $Vault).Replace('{{DATE}}', (Get-Date).ToString('yyyy-MM-dd'))
    [IO.File]::WriteAllText($dst, $text, (New-Object Text.UTF8Encoding $false))
    $script:created += $dst
}

# --- folders -----------------------------------------------------------------
Ensure-Dir $Vault
foreach ($d in '01 - Daily Notes', '02 - Subjects', '03 - Projects', '04 - Routines', '05 - Reference',
               'raw', 'raw\assets', 'outputs', 'feedback', 'Archive') { Ensure-Dir (Join-Path $Vault $d) }
Ensure-Dir (Join-Path $EvieHome '.claude\skills\wiki')

# --- files (never overwritten) ---------------------------------------------------
Place (Join-Path $T 'CLAUDE.md')                 (Join-Path $EvieHome 'CLAUDE.md')
Place (Join-Path $T 'VAULT-INDEX.md')            (Join-Path $Vault 'VAULT-INDEX.md')
Place (Join-Path $T 'vault\index.md')            (Join-Path $Vault 'index.md')
Place (Join-Path $T 'vault\log.md')              (Join-Path $Vault 'log.md')
Place (Join-Path $T 'vault\raw-README.md')       (Join-Path $Vault 'raw\README.md')
Place (Join-Path $T 'vault\outputs-README.md')   (Join-Path $Vault 'outputs\README.md')
Place (Join-Path $T 'GUARDRAILS.md')             (Join-Path $Vault 'GUARDRAILS.md')
Place (Join-Path $T 'PROFILE.md')                (Join-Path $Vault 'Profile.md')
Place (Join-Path $T 'vault\active-priorities.md') (Join-Path $Vault 'Active Priorities.md')
Place (Join-Path $T 'DAILY-NOTE.md')             (Join-Path $Vault '01 - Daily Notes\Daily Note Template.md')
Place (Join-Path $T 'claude\wiki-SKILL.md')      (Join-Path $EvieHome '.claude\skills\wiki\SKILL.md')

# --- hooks: .claude\settings.json (merged, never clobbered) ----------------------
$hooksDir = (Join-Path $Kit 'scripts\hooks').Replace('\', '/')
function HookCmd($f) { "powershell -NoProfile -ExecutionPolicy Bypass -File `"$hooksDir/$f`"" }
$settingsPath = Join-Path $EvieHome '.claude\settings.json'
$want = [ordered]@{
    PreToolUse   = @(@{ matcher = 'Bash|PowerShell'; hooks = @(@{ type = 'command'; command = (HookCmd 'protect-delete.ps1'); timeout = 15 }) })
    PreCompact   = @(@{ hooks = @(@{ type = 'command'; command = (HookCmd 'precompact-marker.ps1'); timeout = 15 }) })
    SessionStart = @(@{ matcher = 'compact'; hooks = @(@{ type = 'command'; command = (HookCmd 'postcompact-sweep.ps1'); timeout = 15 }) })
}
$changed = $false
if (Test-Path $settingsPath) {
    $s = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $s.PSObject.Properties['hooks']) { $s | Add-Member -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{}) }
    foreach ($ev in $want.Keys) {
        $existing = @(); if ($s.hooks.PSObject.Properties[$ev]) { $existing = @($s.hooks.$ev) }
        $already = ($existing | ConvertTo-Json -Depth 10) -match [regex]::Escape(($want[$ev][0].hooks[0].command -split '/')[-1].TrimEnd('"'))
        if (-not $already) {
            $changed = $true
            $merged = @($existing) + $want[$ev]
            if ($s.hooks.PSObject.Properties[$ev]) { $s.hooks.$ev = $merged } else { $s.hooks | Add-Member -NotePropertyName $ev -NotePropertyValue $merged }
        }
    }
    if ($changed) {
        $json = $s | ConvertTo-Json -Depth 12
        Copy-Item $settingsPath "$settingsPath.backup-$((Get-Date).ToString('yyyy-MM-dd-HHmm'))"
        [IO.File]::WriteAllText($settingsPath, $json, (New-Object Text.UTF8Encoding $false))
    }
} else {
    $json = [ordered]@{ hooks = $want } | ConvertTo-Json -Depth 12
    [IO.File]::WriteAllText($settingsPath, $json, (New-Object Text.UTF8Encoding $false))
}
$null = Get-Content $settingsPath -Raw | ConvertFrom-Json   # proves it is valid JSON

$prot = Join-Path $EvieHome '.claude\protected-paths.txt'
if (-not (Test-Path $prot)) {
    $lines = @('# One folder per line. The delete-protection hook guards these in addition to the EVIE folder.')
    if ($VaultPath) { $lines += $VaultPath }
    [IO.File]::WriteAllText($prot, ($lines -join "`r`n") + "`r`n", (New-Object Text.UTF8Encoding $false))
    $created += $prot
}

# --- shortcuts ----------------------------------------------------------------------
if (-not $NoShortcuts) { & (Join-Path $PSScriptRoot 'Make-Shortcuts.ps1') }

Write-Host ''
Write-Host "  EVIE home:  $EvieHome"
Write-Host "  Vault:      $Vault"
Write-Host "  Created:    $($created.Count) item(s)"
if ($kept.Count) { Write-Host "  Kept as-is (already existed, not touched): $($kept.Count)"; $kept | ForEach-Object { Write-Host "    - $_" } }
Write-Host '  Hooks:      delete protection + compaction sweep  ->  .claude\settings.json'
Write-Host ''
Write-Host '  Next: fill every [FILL IN] marker from the interview, then run the vault check:'
Write-Host "    uv run --no-project python `"$Kit\scripts\wiki-lint.py`" `"$Vault`""
