@echo off
rem ============================================================================
rem  evie-env.cmd  -  shared environment for every EVIE window
rem
rem  Usage:  call evie-env.cmd paid
rem          call evie-env.cmd local
rem
rem  Called by the four EVIE-*.bat launchers. Do not double-click this file.
rem  Everything set here is LOCAL to the window that called it - nothing is
rem  written to your Windows environment, so a Local window can never leak into
rem  a Paid one (a permanent ANTHROPIC_BASE_URL is the worst bug this stack has
rem  ever had: Paid silently talks to the local model and just "gets worse").
rem ============================================================================

set "EVIE_MODE=%~1"
if "%EVIE_MODE%"=="" set "EVIE_MODE=paid"

rem Paths come from where THIS file sits, never from a hardcoded folder name.
set "EVIE_SCRIPTS=%~dp0"
rem (Not "pushd & set %CD% & popd" on one line: batch expands %CD% before the
rem  pushd runs, so that form silently returns the CALLER's folder.)
for %%I in ("%~dp0..") do set "EVIE_REPO=%%~fI"
for %%I in ("%~dp0..\..") do set "EVIE_HOME=%%~fI"
set "EVIE_VAULT=%EVIE_HOME%\Vault"
set "EVIE_BACKTALK=%EVIE_HOME%\backtalk"
set "EVIE_LOCAL=%EVIE_HOME%\local"
rem Python and its tools print UTF-8; without this, Windows consoles mangle it.
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"

rem Always start from a clean slate, whichever lane this is.
set "ANTHROPIC_BASE_URL="
set "ANTHROPIC_AUTH_TOKEN="
set "ANTHROPIC_API_KEY="
set "ANTHROPIC_MODEL="
set "ANTHROPIC_SMALL_FAST_MODEL="
set "ANTHROPIC_DEFAULT_HAIKU_MODEL="
set "ANTHROPIC_DEFAULT_SONNET_MODEL="
set "ANTHROPIC_DEFAULT_OPUS_MODEL="
set "CLAUDE_CONFIG_DIR="
set "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="
set "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="
set "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE="

if /i "%EVIE_MODE%"=="local" goto :local_brain

rem ----------------------------------------------------------------- PAID ----
rem Your normal Claude Code profile: the one signed in to your subscription.
rem This is the ONLY lane where "sign in to Anthropic" can ever appear.
set "EVIE_BRAIN_LABEL=Claude (paid subscription)"
goto :done

rem ---------------------------------------------------------------- LOCAL ----
:local_brain
rem The local brain's settings (port, model alias, context) are written by
rem Install-LocalBrain.ps1 for THIS machine's hardware.
if not exist "%EVIE_LOCAL%\brain.cmd" (
  set "EVIE_LOCAL_MISSING=1"
  goto :done
)
call "%EVIE_LOCAL%\brain.cmd"

rem A SEPARATE Claude Code profile that has never been signed in. Pointing at
rem it means: no browser login, no "your subscription expired, sign in" screen,
rem no Anthropic connectors - ever - in local windows, even a year after the
rem subscription lapses. The token below is not a secret; llama.cpp ignores it.
rem It exists so Claude Code uses it instead of asking you to log in.
set "CLAUDE_CONFIG_DIR=%EVIE_LOCAL%\claude-profile"
set "ANTHROPIC_BASE_URL=http://127.0.0.1:%EVIE_LLM_PORT%"
set "ANTHROPIC_AUTH_TOKEN=local-no-login"
set "ANTHROPIC_MODEL=%EVIE_LLM_ALIAS%"
set "ANTHROPIC_SMALL_FAST_MODEL=%EVIE_LLM_ALIAS%"
set "ANTHROPIC_DEFAULT_HAIKU_MODEL=%EVIE_LLM_ALIAS%"
set "ANTHROPIC_DEFAULT_SONNET_MODEL=%EVIE_LLM_ALIAS%"
set "ANTHROPIC_DEFAULT_OPUS_MODEL=%EVIE_LLM_ALIAS%"
set "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1"
rem Offline means offline: no telemetry, no update checks, no Anthropic calls.
set "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1"
rem Claude Code assumes a 200k window for a model it doesn't know. The real one
rem is %EVIE_LLM_CTX%; this compacts at ~80%% of it (the old
rem CLAUDE_CODE_MAX_CONTEXT_TOKENS knob is ignored for custom model ids).
set "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=%EVIE_COMPACT_PCT%"
set "EVIE_BRAIN_LABEL=gpt-oss-20b (local, llama.cpp, %EVIE_LLM_CTX% tokens)"

:done
exit /b 0
