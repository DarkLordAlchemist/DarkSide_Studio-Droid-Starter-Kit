<#
  PreToolUse hook (Bash / PowerShell): if a command would DELETE or MOVE anything
  inside EVIE's folder (or a folder listed in .claude\protected-paths.txt), stop
  and ask the person first. Everything else passes untouched.

  It reads the command text. It cannot see a delete hidden inside a script file
  being run, and it does not cover the Write/Edit tools - the guardrails in
  CLAUDE.md still apply to those. On any internal error it ASKS (fails safe).
#>
$ErrorActionPreference = 'Stop'
function Ask($why) {
    @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'ask'; permissionDecisionReason = $why } } | ConvertTo-Json -Compress -Depth 5
    exit 0
}
try {
    $data = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $cmd = "$($data.tool_input.command)"
    $verbs = '(?<![\w-])(rm|rmdir|unlink|shred|del|erase|rd|mv|move|remove-item|move-item|ri|rni|git\s+rm|git\s+clean|git\s+mv)(?![\w-])|-delete\b|rmtree|os\.remove|os\.unlink|os\.rmdir|\.unlink\(|os\.replace|shutil\.move'
    if ($cmd -notmatch $verbs) { exit 0 }

    function Norm([string]$s) {
        $s = $s.Replace('\\', '/').Replace('\', '/').ToLower()
        $s = [regex]::Replace($s, '(?<![\w:])/([a-z])/', '$1:/')                     # /c/users -> c:/users
        $u = $env:USERPROFILE.Replace('\', '/').ToLower()
        $s = $s.Replace('~/', "$u/").Replace('$home/', "$u/").Replace('$env:userprofile/', "$u/").Replace('%userprofile%/', "$u/")
        return $s
    }
    $evieHome = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
    $roots = @((Norm $evieHome).TrimEnd('/'))
    $extra = Join-Path $evieHome '.claude\protected-paths.txt'
    if (Test-Path $extra) { Get-Content $extra | Where-Object { $_.Trim() -and -not $_.StartsWith('#') } | ForEach-Object { $roots += (Norm $_.Trim()).TrimEnd('/') } }

    $n = Norm $cmd
    $hits = @($roots | Where-Object { $n.Contains($_) })
    # Working folder: an explicit leading `cd X` wins, otherwise the session's.
    $cwd = (Norm "$($data.cwd)").TrimEnd('/')
    $m = [regex]::Match($n, '(?:^|&&|;|\|\|)\s*(?:cd|set-location|sl|pushd)\s+["'']?([^"'';&|]+?)["'']?\s*(?:&&|;|\|\||$)')
    if ($m.Success) { $cwd = $m.Groups[1].Value.Trim().TrimEnd('/') }
    $rest = if ($cwd) { $n.Replace($cwd, '') } else { $n }
    $hasAbs = $rest -match '[a-z]:/|(?<![\w.~])/(tmp|dev|var|usr|etc|mnt)/'
    $inRoot = @($roots | Where-Object { $cwd -eq $_ -or $cwd.StartsWith("$_/") }).Count -gt 0
    if ($hits.Count -gt 0 -or ($inRoot -and -not $hasAbs)) {
        $where = if ($hits.Count) { ($hits | Select-Object -Unique) -join ', ' } else { $cwd }
        Ask "EVIE delete-protection: this command deletes or moves something in a protected folder ($where). Approve only if you meant it."
    }
    exit 0
} catch {
    Ask "EVIE delete-protection hook hit an error ($($_.Exception.GetType().Name)); asking to be safe."
}
