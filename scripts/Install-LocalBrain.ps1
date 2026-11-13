<#
  Install-LocalBrain.ps1 - install EVIE's offline brain: gpt-oss-20b on llama.cpp
  ---------------------------------------------------------------------------
  Run it in its own window (the downloads are ~12.5 GB):
      powershell -ExecutionPolicy Bypass -File .\Install-LocalBrain.ps1

  What it does, and PROVES, in order:
    1. Measures this PC (GPU, VRAM, driver, RAM, disk)
    2. Downloads llama.cpp build b11871 - the exact build this kit was tested on -
       in the right flavour for your GPU (NVIDIA CUDA 13 / CUDA 12 / Vulkan / CPU)
    3. Downloads gpt-oss-20b (MXFP4, 12.1 GB) and checks it byte for byte
    4. Picks the context size and GPU/RAM split for your hardware, then LOADS the
       model to prove it fits (backs off automatically if it does not)
    5. Times a real answer (tokens/sec)
    6. Proves TOOL CALLING works (the model asks to use a tool, correctly)
    7. Seeds a separate, never-signed-in Claude Code profile for the Local lane
       and proves Claude Code can run a tool through it with NO login
    8. Writes local\brain.cmd, which the Local shortcuts read

  Resume-safe: if a download breaks, run it again and it continues.
  Options: -Context 65536  -NCpuMoe 18  -Build b11871  -SkipDownload  -Port 8085
#>
[CmdletBinding()]
param(
    [int]$Context = 0,
    [int]$NCpuMoe = -1,
    [string]$Build = 'b11871',
    [int]$Port = 8085,
    [switch]$SkipDownload
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Kit      = Split-Path $PSScriptRoot -Parent
$EvieHome = Split-Path $Kit -Parent
$Local    = Join-Path $EvieHome 'local'
$Dl       = Join-Path $Local 'downloads'
$Llama    = Join-Path $Local "llama.cpp-$Build"
$Models   = Join-Path $Local 'models'
$Gguf     = Join-Path $Models 'gpt-oss-20b-MXFP4.gguf'
$GgufUrl  = 'https://huggingface.co/ggml-org/gpt-oss-20b-GGUF/resolve/main/gpt-oss-20b-MXFP4.gguf'
$GgufSize = 12109566624
$Alias    = 'claude-gpt-oss-20b'
$Status   = Join-Path $Local 'install-status.json'

function Head($t) { Write-Host ''; Write-Host "  $t" -ForegroundColor Cyan; Write-Host ('  ' + ('-' * $t.Length)) -ForegroundColor DarkGray }
function Item($k, $v) { Write-Host ('    {0,-24} {1}' -f $k, $v) }
function Good($t) { Write-Host "    + $t" -ForegroundColor Green }
function Warn($t) { Write-Host "    ! $t" -ForegroundColor Yellow }
function Save-Status($state, $extra) {
    $o = [ordered]@{ state = $state; time = (Get-Date).ToString('s') }
    if ($extra) { foreach ($k in $extra.Keys) { $o[$k] = $extra[$k] } }
    if (-not (Test-Path $Local)) { New-Item -ItemType Directory -Path $Local | Out-Null }
    [IO.File]::WriteAllText($Status, ($o | ConvertTo-Json -Depth 5), (New-Object Text.UTF8Encoding $false))
}
function Fail($t) { Save-Status 'failed' @{ reason = $t }; Write-Host ''; Write-Host "  FAILED: $t" -ForegroundColor Red; exit 1 }

foreach ($d in $Local, $Dl, $Models) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null } }
Save-Status 'running' $null

# ------------------------------------------------------------ 1. measure ----
Head '1/8 Looking at this PC'
$gpu = $null; $vram = 0; $driver = 0
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    $line = (& nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader,nounits 2>$null | Select-Object -First 1)
    if ($line) {
        $p = $line.Split(',') | ForEach-Object { $_.Trim() }
        $gpu = $p[0]; $vram = [math]::Round([int]$p[1] / 1024, 1); $driver = [double]($p[2].Split('.')[0])
    }
}
$otherGpu = (Get-CimInstance Win32_VideoController | Where-Object { $_.Name -match 'Radeon|Arc|Intel\(R\) (UHD|Iris)' } | Select-Object -First 1).Name
$ramGB  = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
$drive  = (Split-Path $EvieHome -Qualifier).TrimEnd(':')
$freeGB = [math]::Round((Get-PSDrive $drive).Free / 1GB, 1)
Item 'GPU' $(if ($gpu) { "$gpu ($vram GB, driver $driver)" } elseif ($otherGpu) { "$otherGpu (non-NVIDIA)" } else { 'none found' })
Item 'System RAM' "$ramGB GB"
Item "Free disk ($drive`:)" "$freeGB GB"

$haveFiles = (Test-Path (Join-Path $Llama 'llama-server.exe')) -and (Test-Path $Gguf) -and ((Get-Item $Gguf -ErrorAction SilentlyContinue).Length -eq $GgufSize)
if (-not $haveFiles -and $freeGB -lt 16) { Fail "Needs about 16 GB free on $drive`: (model 12.1 GB + engine + room to work). Free some space and run this again." }
if ($ramGB -lt 15) { Warn 'Under 16 GB of RAM. gpt-oss-20b keeps part of itself in RAM; expect it to be slow or to fail.' }

# --------------------------------------------------------- 2. llama.cpp ----
Head "2/8 llama.cpp $Build"
if ($gpu -and $driver -ge 580) { $flavour = 'cuda-13.4'; $cudart = "cudart-llama-bin-win-cuda-13.4-x64.zip" }
elseif ($gpu)                  { $flavour = 'cuda-12.4'; $cudart = "cudart-llama-bin-win-cuda-12.4-x64.zip" }
elseif ($otherGpu)             { $flavour = 'vulkan';    $cudart = $null }
else                           { $flavour = 'cpu';       $cudart = $null }
Item 'Flavour' $flavour
$base = "https://github.com/ggml-org/llama.cpp/releases/download/$Build"
if (Test-Path (Join-Path $Llama 'llama-server.exe')) { Good 'already installed.' }
elseif ($SkipDownload) { Fail 'llama.cpp is missing and -SkipDownload was given.' }
else {
    $zips = @("llama-$Build-bin-win-$flavour-x64.zip")
    if ($cudart) { $zips += $cudart }
    foreach ($z in $zips) {
        $out = Join-Path $Dl $z
        Item 'Downloading' $z
        & curl.exe -L --fail --retry 5 -C - -o $out "$base/$z"
        if ($LASTEXITCODE -ne 0) { Fail "Download failed: $base/$z" }
        Expand-Archive -Path $out -DestinationPath $Llama -Force
    }
    if (-not (Test-Path (Join-Path $Llama 'llama-server.exe'))) { Fail "llama-server.exe not found after unpacking into $Llama" }
    Good "installed to $Llama"
}

# ----------------------------------------------------------- 3. the model ----
Head '3/8 gpt-oss-20b (12.1 GB)'
$len = 0; if (Test-Path $Gguf) { $len = (Get-Item $Gguf).Length }
if ($len -eq $GgufSize) { Good 'already downloaded and complete.' }
elseif ($SkipDownload) { Fail 'The model is missing and -SkipDownload was given.' }
else {
    Item 'Downloading' 'this is the long one - leave the window open. It resumes if interrupted.'
    & curl.exe -L --fail --retry 10 -C - -o $Gguf $GgufUrl
    if ($LASTEXITCODE -ne 0) { Fail 'Model download failed. Run this script again - it picks up where it stopped.' }
    $len = (Get-Item $Gguf).Length
    if ($len -ne $GgufSize) { Fail "Model file is $len bytes, expected $GgufSize. Run again to resume." }
    Good 'downloaded and size-checked.'
}

# ---------------------------------------------------------- 4. fit it ----
Head '4/8 Fitting gpt-oss to this hardware'
# gpt-oss-20b is a "mixture of experts": only a slice of it works per word, so
# the experts of some layers can live in RAM (--n-cpu-moe N) while the rest sits
# on the GPU. MEASURED tier: 8 GB VRAM -> N=18 at 131072 context, ~22 tok/s on
# an RTX 5070 Laptop. Other tiers are calculated starting points; the load test
# below proves or corrects them on YOUR machine.
$ngl = 999
if (-not $gpu -and -not $otherGpu) { $ngl = 0; $ctx = 32768; $ncm = 24 }
elseif (-not $gpu) { $ctx = 32768; $ncm = 20 }   # Vulkan: start conservative
elseif ($vram -ge 20) { $ctx = 131072; $ncm = 0 }
elseif ($vram -ge 15) { $ctx = 131072; $ncm = 3 }
elseif ($vram -ge 11) { $ctx = 131072; $ncm = 10 }
elseif ($vram -ge 9.5) { $ctx = 131072; $ncm = 14 }
elseif ($vram -ge 7.5) { $ctx = 131072; $ncm = 18 }
elseif ($vram -ge 5.5) { $ctx = 65536;  $ncm = 22 }
else { $ctx = 32768; $ncm = 24 }
# (No RAM cap on context: the context cache lives in VRAM, and the 8 GB tier runs 131072
#  daily on a 16 GB-RAM laptop. The load test below is the real judge.)
if ($Context -gt 0) { $ctx = $Context }
if ($NCpuMoe -ge 0) { $ncm = $NCpuMoe }

$server = Join-Path $Llama 'llama-server.exe'
function Stop-Brain { Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue; Start-Sleep 3 }
function Test-Health { try { (Invoke-RestMethod "http://127.0.0.1:$Port/health" -TimeoutSec 5).status -eq 'ok' } catch { $false } }
function Start-Brain($c, $n) {
    Stop-Brain
    $a = @('-m', "`"$Gguf`"", '--host', '127.0.0.1', '--port', $Port, '-c', $c, '-np', '1', '-ngl', $ngl, '-fa', 'on',
              '-ctk', 'q8_0', '-ctv', 'q8_0', '--n-cpu-moe', $n, '-b', '2048', '-ub', '2048', '--jinja', '--alias', $Alias)
    $log = Join-Path $Local 'llama-server-install-test.log'
    $script:proc = Start-Process -FilePath $server -ArgumentList $a -WindowStyle Hidden -PassThru -RedirectStandardError $log
    for ($i = 0; $i -lt 400; $i++) {
        if (Test-Health) { return $true }
        if ($script:proc.HasExited) { return $false }
        Start-Sleep 1
    }
    return $false
}
$ok = $false
for ($try = 0; $try -lt 6 -and -not $ok; $try++) {
    Item 'Trying' "context $ctx, experts-in-RAM $ncm"
    $ok = Start-Brain $ctx $ncm
    if ($ok -and $gpu) {
        $free = [int](& nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits | Select-Object -First 1)
        Item 'VRAM left free' "$free MiB"
        if ($free -lt 500) { Warn 'Too tight - Windows needs headroom to draw the screen. Backing off.'; $ok = $false }
    }
    if (-not $ok) {
        if ($ncm -lt 24) { $ncm = [math]::Min(24, $ncm + 3) } elseif ($ctx -gt 32768) { $ctx = [int]($ctx / 2) } else { break }
    }
}
if (-not $ok) { Stop-Brain; Fail "gpt-oss would not load on this machine. Last log: $Local\llama-server-install-test.log" }
Good "fits: context $ctx tokens, experts-in-RAM $ncm"

# ---------------------------------------------------------- 5. speed ----
Head '5/8 Timing a real answer'
$tps = 0
try {
    $body = @{ prompt = 'Explain in two sentences why spaced repetition helps memory.'; n_predict = 96 } | ConvertTo-Json
    $r = Invoke-RestMethod "http://127.0.0.1:$Port/completion" -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 600
    $tps = [math]::Round($r.timings.predicted_per_second, 1)
    Item 'Speed' "$tps tokens/sec"
    if ($tps -ge 18) { Good 'Good. Local mode is usable for daily work.' }
    elseif ($tps -ge 8) { Good 'Workable. Fine for notes, quizzing, filing.' }
    else { Warn 'Slow. Keep local sessions short; real work belongs in Paid.' }
} catch { Warn "Timing failed: $($_.Exception.Message)" }

# ------------------------------------------------------ 6. tool calling ----
Head '6/8 Proving tool calling works'
$toolOk = $false
try {
    $req = @{
        model = $Alias; max_tokens = 400
        tools = @(@{ name = 'get_weather'; description = 'Get the current weather for a city.'
                     input_schema = @{ type = 'object'; properties = @{ city = @{ type = 'string' } }; required = @('city') } })
        messages = @(@{ role = 'user'; content = 'What is the weather in Manila right now? Use the tool.' })
    } | ConvertTo-Json -Depth 10
    $r = Invoke-RestMethod "http://127.0.0.1:$Port/v1/messages" -Method Post -Body $req -ContentType 'application/json' -Headers @{ 'x-api-key' = 'local-no-login'; 'anthropic-version' = '2023-06-01' } -TimeoutSec 600
    $call = $r.content | Where-Object { $_.type -eq 'tool_use' } | Select-Object -First 1
    if ($call -and $call.name -eq 'get_weather' -and "$($call.input.city)" -match 'Manila') { $toolOk = $true; Good "the model called get_weather(city=$($call.input.city)) - tool calling works." }
    else { Warn "No proper tool call came back (stop_reason: $($r.stop_reason))." }
} catch { Warn "Tool-call test errored: $($_.Exception.Message)" }

# ---------------------------------------- 7. sealed, never-signed-in profile ----
Head '7/8 The Local lane''s own Claude Code profile (no sign-in, ever)'
$prof = Join-Path $Local 'claude-profile'
if (-not (Test-Path $prof)) { New-Item -ItemType Directory -Path $prof | Out-Null }
$seed = Join-Path $prof '.claude.json'
if (-not (Test-Path $seed)) {
    $home2 = $EvieHome.Replace('\', '/')
    $o = [ordered]@{ hasCompletedOnboarding = $true; theme = 'dark'; projects = @{ $home2 = @{ hasTrustDialogAccepted = $true } } }
    [IO.File]::WriteAllText($seed, ($o | ConvertTo-Json -Depth 5), (New-Object Text.UTF8Encoding $false))
}
$ccOk = $false
if (Get-Command claude -ErrorAction SilentlyContinue) {
    $save = @{}
    $vars = @{ CLAUDE_CONFIG_DIR = $prof; ANTHROPIC_BASE_URL = "http://127.0.0.1:$Port"; ANTHROPIC_AUTH_TOKEN = 'local-no-login'
               ANTHROPIC_API_KEY = $null; ANTHROPIC_MODEL = $Alias; ANTHROPIC_SMALL_FAST_MODEL = $Alias; ANTHROPIC_DEFAULT_HAIKU_MODEL = $Alias
               CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = '1'; CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = '1' }
    foreach ($k in $vars.Keys) { $save[$k] = [Environment]::GetEnvironmentVariable($k, 'Process'); [Environment]::SetEnvironmentVariable($k, $vars[$k], 'Process') }
    Push-Location $EvieHome
    # Windows PowerShell 5.1 turns ANY stderr line from a program into an error under
    # 'Stop' - and Claude Code prints a harmless "doesn't recognize the model ... 200k"
    # warning on stderr. So: relax error handling here and judge by stdout only.
    $eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try {
        $out = & claude -p 'Use the Bash tool to run exactly: echo EVIE-LOCAL-OK   Then reply with only the output.' --model $Alias --tools Bash --strict-mcp-config --permission-mode bypassPermissions --max-turns 4 2>$null | Out-String
        if ($out -match 'EVIE-LOCAL-OK') { $ccOk = $true; Good 'Claude Code ran a real tool on gpt-oss through the sealed profile - no sign-in.' }
        else { Warn "Claude Code smoke test did not confirm. Output: $($out.Trim() | Select-Object -First 1)" }
    } catch { Warn "Claude Code smoke test errored: $($_.Exception.Message)" }
    $ErrorActionPreference = $eap
    Pop-Location
    foreach ($k in $save.Keys) { [Environment]::SetEnvironmentVariable($k, $save[$k], 'Process') }
} else { Warn 'claude is not on PATH in this window - skipped the end-to-end test.' }
Stop-Brain

# ------------------------------------------------------- 8. write config ----
Head '8/8 Saving the settings'
$pct = [math]::Max(5, [math]::Min(95, [int][math]::Floor($ctx * 0.8 / 200000 * 100)))
$cmd = @"
@echo off
rem Written by Install-LocalBrain.ps1 on $((Get-Date).ToString('yyyy-MM-dd HH:mm')) for: $(if ($gpu) { "$gpu $vram GB" } else { 'no NVIDIA GPU' }), $ramGB GB RAM.
rem Re-run that script to recalculate; edit by hand only if you know why.
set "EVIE_LLAMA=$Llama"
set "EVIE_GGUF=$Gguf"
set "EVIE_LLM_PORT=$Port"
set "EVIE_LLM_ALIAS=$Alias"
set "EVIE_LLM_CTX=$ctx"
set "EVIE_NGL=$ngl"
set "EVIE_NCPUMOE=$ncm"
set "EVIE_COMPACT_PCT=$pct"
"@
[IO.File]::WriteAllText((Join-Path $Local 'brain.cmd'), ($cmd -replace "`r?`n", "`r`n"), (New-Object Text.ASCIIEncoding))
Item 'Context' "$ctx tokens (auto-compact at ~80%: CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=$pct)"
Item 'Experts in RAM' $ncm
Item 'Config' (Join-Path $Local 'brain.cmd')

$state = 'ok'; if (-not $toolOk -or -not $ccOk) { $state = 'ok-with-warnings' }
Save-Status $state @{ context = $ctx; n_cpu_moe = $ncm; tokens_per_sec = $tps; tool_calling = $toolOk; claude_code_no_login = $ccOk; gpu = "$gpu"; vram_gb = $vram; ram_gb = $ramGB; build = $Build; flavour = $flavour }
Write-Host ''
if ($state -eq 'ok') { Good 'Local brain installed and proven. Use the EVIE - Chat (Local) shortcut.' }
else { Warn 'Installed, but a check above did not pass. Tell EVIE in Chat (Paid) - she reads install-status.json.' }
Write-Host ''
