<#
  Set-OllamaTuning.ps1
  ---------------------------------------------------------------------------
  Measures this machine, picks the largest context window it can actually
  sustain, writes the settings permanently, restarts Ollama, and then MEASURES
  the result instead of assuming it worked.

  Run it once, at install. Run it again if the hardware changes.

  Right-click the file and choose "Run with PowerShell", or from a terminal:
      powershell -ExecutionPolicy Bypass -File .\Set-OllamaTuning.ps1

  Options:
      -Context 65536     Override the chosen context length
      -Model  <tag>      Benchmark a different model (default ornith-1.5:9b)
      -NoBenchmark       Skip the timing test
      -WhatIf            Show what it would set, change nothing
  ---------------------------------------------------------------------------
  Why this script exists: OLLAMA_CONTEXT_LENGTH cannot be set from a terminal
  window or a batch file. Ollama runs as a background service and reads its
  settings when IT starts. Setting it anywhere else looks like it worked and
  silently does nothing - which shows up later as "EVIE forgets what she was
  doing", and gets blamed on the model.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [int]$Context = 0,
    [string]$Model = 'ornith-1.5:9b',
    [switch]$NoBenchmark
)

$ErrorActionPreference = 'Stop'

function Write-Head($t) { Write-Host ''; Write-Host "  $t" -ForegroundColor Cyan; Write-Host ('  ' + ('-' * $t.Length)) -ForegroundColor DarkGray }
function Write-Item($k, $v) { Write-Host ('    {0,-22} {1}' -f $k, $v) }
function Write-Warn($t) { Write-Host "    ! $t" -ForegroundColor Yellow }
function Write-Good($t) { Write-Host "    + $t" -ForegroundColor Green }

# ---------------------------------------------------------------- detect ----

function Get-VramGB {
    # 1. nvidia-smi is authoritative when it exists.
    if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
        try {
            $mb = & nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>$null |
                  ForEach-Object { [int]($_.Trim()) } | Sort-Object -Descending | Select-Object -First 1
            if ($mb -gt 0) { return [math]::Round($mb / 1024, 1) }
        } catch { }
    }
    # 2. Registry holds a real 64-bit value. Win32_VideoController does not -
    #    its AdapterRAM field is a 32-bit int and reports 4 GB for every card
    #    above 4 GB, which is exactly the range we care about.
    $best = 0
    $classKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    Get-ChildItem $classKey -ErrorAction SilentlyContinue | ForEach-Object {
        $p = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
        $v = $p.'HardwareInformation.qwMemorySize'
        if ($v -and [int64]$v -gt $best) { $best = [int64]$v }
    }
    if ($best -gt 0) { return [math]::Round($best / 1GB, 1) }
    return 0
}

function Get-GpuName {
    $g = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue |
         Where-Object { $_.Name -notmatch 'Basic Display|Remote|Virtual|Meta|Parsec' } |
         Select-Object -First 1
    if ($g) { return $g.Name } else { return 'unknown' }
}

Write-Head 'Looking at your hardware'

$vram    = Get-VramGB
$gpuName = Get-GpuName
$ramGB   = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
$freeGB  = [math]::Round((Get-PSDrive C).Free / 1GB, 1)

Write-Item 'GPU'          $gpuName
Write-Item 'VRAM'         $(if ($vram -gt 0) { "$vram GB" } else { 'not detected' })
Write-Item 'System RAM'   "$ramGB GB"
Write-Item 'Free disk (C)' "$freeGB GB"

if ($vram -eq 0) {
    Write-Warn 'No dedicated GPU memory found. EVIE will run on the CPU: expect'
    Write-Warn 'a few words per second. Usable for short questions, painful for work.'
}

# ---------------------------------------------------------------- choose ----

Write-Head 'Choosing your context window'

# The context (KV) cache grows with context length and, past about 32K, can use
# more memory than the model weights. These tiers assume q8_0 cache and a single
# concurrent request, and leave room for Windows to keep drawing your screen.
# Model max for ornith-1.5 is 256K, so that is the ceiling.
function Get-ContextForVram([double]$v) {
    if ($v -ge 24) { return 262144 }
    if ($v -ge 16) { return 131072 }
    if ($v -ge 12) { return 65536  }
    if ($v -ge 10) { return 49152  }
    if ($v -ge 8)  { return 32768  }
    if ($v -ge 6)  { return 16384  }
    return 8192
}

$chosen = Get-ContextForVram $vram
$reason = "$vram GB VRAM"

# Anything that will not fit in VRAM spills into system RAM, so RAM is a real
# second ceiling and not a formality.
if ($ramGB -lt 16 -and $chosen -gt 16384) { $chosen = 16384; $reason = "$ramGB GB RAM (capped)" }
elseif ($ramGB -lt 32 -and $chosen -gt 65536) { $chosen = 65536; $reason = "$ramGB GB RAM (capped)" }

if ($Context -gt 0) { $chosen = $Context; $reason = 'set by hand with -Context' }

Write-Item 'Context length' "$chosen tokens   ($reason)"

if ($chosen -lt 32768) {
    Write-Warn 'Below 32K, long tasks will drift. Keep local mode for short,'
    Write-Warn 'self-contained jobs and use the Cloud shortcut for real work.'
} else {
    Write-Good 'Comfortable for agentic work.'
}

if ($vram -gt 0 -and $vram -lt 8) {
    Write-Warn "ornith-1.5:9b needs about 6.5 GB before any context. On $vram GB it will"
    Write-Warn 'spill heavily into system RAM. A smaller model may serve you better.'
}

# ------------------------------------------------------------------ write ----

Write-Head 'Writing the settings permanently'

$settings = [ordered]@{
    # The big one. Must be a user environment variable; Ollama reads it at start.
    OLLAMA_CONTEXT_LENGTH  = "$chosen"
    # Halves the memory the context cache uses, for a quality difference nobody
    # has ever noticed in practice.
    OLLAMA_KV_CACHE_TYPE   = 'q8_0'
    # One student, one machine, one request at a time. This matters more than it
    # looks: concurrent slots each get their own context cache, so leaving this
    # at the default can multiply your VRAM use and undo everything above.
    OLLAMA_NUM_PARALLEL    = '1'
    OLLAMA_MAX_LOADED_MODELS = '1'
    # Keep the model warm between questions, release the VRAM eventually.
    OLLAMA_KEEP_ALIVE      = '15m'
}

foreach ($k in $settings.Keys) {
    $v = $settings[$k]
    $old = [Environment]::GetEnvironmentVariable($k, 'User')
    if ($PSCmdlet.ShouldProcess("user environment variable $k", "set to $v")) {
        [Environment]::SetEnvironmentVariable($k, $v, 'User')
        $env:"$k" = $v
        if ($old -and $old -ne $v) { Write-Item $k "$v   (was $old)" }
        else { Write-Item $k $v }
    }
}

if ($WhatIfPreference) { Write-Host ''; Write-Host '  -WhatIf: nothing was changed.'; return }

# ---------------------------------------------------------------- restart ----

Write-Head 'Restarting Ollama so it picks these up'

$wasRunning = $false
Get-Process -Name 'ollama app', 'ollama' -ErrorAction SilentlyContinue | ForEach-Object {
    $wasRunning = $true
    try { $_ | Stop-Process -Force -ErrorAction Stop } catch { }
}
Start-Sleep -Seconds 2

$trayApp = Join-Path $env:LOCALAPPDATA 'Programs\Ollama\ollama app.exe'
if (Test-Path $trayApp) {
    Start-Process $trayApp
    Write-Good 'Ollama restarted.'
    Start-Sleep -Seconds 6
} elseif ($wasRunning) {
    Write-Warn 'Stopped Ollama but could not find it to start again.'
    Write-Warn 'Start it from the Start menu, then re-run this script to verify.'
    return
} else {
    Write-Warn 'Ollama does not appear to be installed yet.'
    Write-Warn 'Settings are saved. Install Ollama from ollama.com, then re-run this.'
    return
}

# --------------------------------------------------------------- verify -----

Write-Head 'Checking it actually took'

try {
    $null = Invoke-RestMethod 'http://localhost:11434/api/version' -TimeoutSec 20
    Write-Good 'Ollama is responding on port 11434.'
} catch {
    Write-Warn 'Ollama is not responding yet. Give it a minute, then run: ollama list'
    return
}

$have = (& ollama list 2>$null) -join "`n"
if ($have -notmatch [regex]::Escape($Model.Split(':')[0])) {
    Write-Warn "$Model is not downloaded yet. Get it with:"
    Write-Host  "      ollama pull $Model" -ForegroundColor White
    return
}

if ($NoBenchmark) { Write-Host ''; Write-Host '  Done.'; return }

Write-Head 'Timing a real answer (this loads the model, so be patient)'

try {
    $body = @{ model = $Model; prompt = 'In two sentences, why is spaced repetition effective?'; stream = $false } | ConvertTo-Json
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $r  = Invoke-RestMethod 'http://localhost:11434/api/generate' -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 600
    $sw.Stop()

    $tps = if ($r.eval_duration -gt 0) { [math]::Round($r.eval_count / ($r.eval_duration / 1e9), 1) } else { 0 }
    Write-Item 'Speed' "$tps tokens/sec"
    Write-Item 'Model load + answer' ("{0:N0} seconds" -f $sw.Elapsed.TotalSeconds)

    if     ($tps -ge 25) { Write-Good 'Fast. Local mode is genuinely usable for daily work.' }
    elseif ($tps -ge 12) { Write-Good 'Workable. Fine for notes, quizzing, and filing.' }
    elseif ($tps -ge 5)  { Write-Warn 'Slow but survivable. Keep local sessions short.' }
    else                 { Write-Warn 'Very slow - the model is running mostly on your CPU.' }
} catch {
    Write-Warn "Benchmark failed: $($_.Exception.Message)"
}

Write-Head 'Where the model is actually running'
& ollama ps
Write-Host ''
Write-Host '    100% GPU means it all fits in VRAM. A CPU percentage means part of' -ForegroundColor DarkGray
Write-Host '    it spilled into system RAM - that is what makes it slow.'          -ForegroundColor DarkGray

if ($tps -and $tps -lt 12) {
    Write-Head 'If you want it faster, in this order'
    Write-Host "    1. Close your browser. Chrome can hold over a gigabyte of VRAM."
    Write-Host "    2. Re-run with a smaller window:  .\Set-OllamaTuning.ps1 -Context $([math]::Max(8192, [int]($chosen/2)))"
    Write-Host "    3. Set OLLAMA_KV_CACHE_TYPE to q4_0 instead of q8_0."
    Write-Host "    4. Use a smaller model, or just use the Cloud shortcut for heavy work."
}

Write-Host ''
Write-Good 'Tuning complete. Open EVIE - Chat (Local) and say hello.'
Write-Host ''
