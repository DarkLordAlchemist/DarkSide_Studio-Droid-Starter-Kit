<#
  install.ps1 - EVIE one-paste installer
  -------------------------------------------------------------------------
  Paste this ONE line into Windows PowerShell (not as Administrator):

      irm https://raw.githubusercontent.com/DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit/main/install.ps1 | iex

  What it does, in order, and only what is missing:
    1. Installs Claude Code (Anthropic's official installer)
    2. Installs Git for Windows  (winget)
    3. Installs uv, the Python tool the voice engine runs on  (winget)
    4. Downloads this kit to  %USERPROFILE%\EVIE\droid-kit   (or updates it)
    5. Starts Claude Code in that folder with "read SETUP.md and set me up"

  From step 5 on it is a conversation: EVIE interviews you, builds her memory,
  installs the voice and (if you want it) the offline gpt-oss brain, and puts
  the shortcuts on your Desktop. You need a Claude subscription for this first
  run - after that, the LOCAL shortcuts never ask you to sign in again.

  Safe to run twice. It never deletes anything.
#>

$ErrorActionPreference = 'Stop'
$RepoUrl  = 'https://github.com/DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit.git'
$EvieHome = Join-Path $env:USERPROFILE 'EVIE'
$Kit      = Join-Path $EvieHome 'droid-kit'

function Say($t)  { Write-Host "  $t" }
function Head($t) { Write-Host ''; Write-Host "  == $t ==" -ForegroundColor Cyan }
function Warn($t) { Write-Host "  ! $t" -ForegroundColor Yellow }

# Make tools installed a moment ago visible in THIS window, without a restart.
# (The #1 first-day failure in the old guide was "claude is not recognized"
#  because the window predated the install.)
function Refresh-Path {
    $m = [Environment]::GetEnvironmentVariable('Path','Machine')
    $u = [Environment]::GetEnvironmentVariable('Path','User')
    $env:Path = "$m;$u;$env:USERPROFILE\.local\bin"
}
function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

Write-Host ''
Write-Host '  EVIE installer - DarkSide Studio Droid Starter Kit' -ForegroundColor Green
Write-Host '  This takes 5-10 minutes before the interview starts.'

# A permanent ANTHROPIC_BASE_URL makes the paid brain silently talk to a local
# model. It is the nastiest bug this stack has ever had, so check it first.
foreach ($v in 'ANTHROPIC_BASE_URL','ANTHROPIC_AUTH_TOKEN','ANTHROPIC_API_KEY','CLAUDE_CONFIG_DIR') {
    if ([Environment]::GetEnvironmentVariable($v,'User')) {
        Warn "$v is set permanently in your Windows user environment."
        Warn 'EVIE sets this per-window on purpose. Leaving it can break the paid lane.'
        Warn "Remove it with:  [Environment]::SetEnvironmentVariable('$v', `$null, 'User')"
    }
}

Head '1/5 Claude Code'
Refresh-Path
if (Have 'claude') { Say "already installed: $(claude --version)" }
else {
    Say 'installing (official Anthropic installer) . . .'
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
    Refresh-Path
    if (-not (Have 'claude')) { throw 'Claude Code did not install. Read the messages above, then run this line again.' }
    Say "installed: $(claude --version)"
}

$hasWinget = Have 'winget'
if (-not $hasWinget) { Warn 'winget (the Windows app installer) is missing. Update "App Installer" from the Microsoft Store, then run this again.' }

Head '2/5 Git for Windows'
if (Have 'git') { Say "already installed: $(git --version)" }
elseif ($hasWinget) {
    Say 'installing via winget . . .'
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements --silent
    Refresh-Path; $env:Path += ";$env:ProgramFiles\Git\cmd"
    if (-not (Have 'git')) { throw 'Git did not install. Install it from https://git-scm.com/downloads/win and run this again.' }
}

Head '3/5 uv (runs the voice engine and the memory checker)'
if (Have 'uv') { Say 'already installed.' }
elseif ($hasWinget) {
    winget install --id astral-sh.uv -e --source winget --accept-package-agreements --accept-source-agreements --silent
    Refresh-Path
    if (-not (Have 'uv')) { Warn 'uv did not install. Voice can be set up later; EVIE will offer.' }
}

Head '4/5 Downloading the kit'
if (-not (Test-Path $EvieHome)) { New-Item -ItemType Directory -Path $EvieHome | Out-Null }
if (Test-Path (Join-Path $Kit '.git')) {
    Say "found $Kit - updating it . . ."
    git -C $Kit pull --ff-only
} elseif (Test-Path $Kit) {
    throw "$Kit exists but is not a git download. Rename it (it is never deleted) and run this again."
} else {
    git clone $RepoUrl $Kit
}

Head '5/5 Starting EVIE''s setup'
Say 'Claude Code will open your browser ONCE to sign in to your Claude subscription.'
Say 'After that, answer EVIE''s questions. Close nothing until she says she is done.'
Write-Host ''
Set-Location $Kit
# Clear any local-model wiring so setup always runs on the paid brain.
foreach ($v in 'ANTHROPIC_BASE_URL','ANTHROPIC_AUTH_TOKEN','ANTHROPIC_API_KEY','ANTHROPIC_MODEL','CLAUDE_CONFIG_DIR') { Remove-Item "env:$v" -ErrorAction SilentlyContinue }
claude "read SETUP.md and set me up"
