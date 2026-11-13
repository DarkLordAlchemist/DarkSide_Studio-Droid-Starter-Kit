<#
  PreCompact hook: append a marker to the vault's log.md just before Claude Code
  compresses the conversation. Never blocks compaction (always exits 0).
  The real "save what matters" sweep runs right AFTER compaction - see
  postcompact-sweep.ps1 - because a hook cannot make the model write anything.
#>
try {
    $evieHome = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
    $log = if ($env:EVIE_LOG_PATH_TEST) { $env:EVIE_LOG_PATH_TEST } else { Join-Path $evieHome 'Vault\log.md' }
    $trigger = 'unknown'
    try { $trigger = ([Console]::In.ReadToEnd() | ConvertFrom-Json).trigger } catch { }
    $now = Get-Date
    $entry = "`n## [$($now.ToString('yyyy-MM-dd'))] session | context compaction ($trigger, $($now.ToString('HH:mm')))`n- Automatic marker (PreCompact hook). Lessons not yet saved are swept from the summary right after.`n"
    if (Test-Path (Split-Path $log -Parent)) {
        [IO.File]::AppendAllText($log, $entry, (New-Object Text.UTF8Encoding $false))
    }
} catch { }
exit 0
