@echo off
rem ============================================================================
rem  evie-env.cmd  -  shared environment for every EVIE window
rem
rem  Usage:  call evie-env.cmd cloud
rem          call evie-env.cmd local
rem
rem  Called by the four EVIE-*.bat launchers. Do not double-click this file.
rem
rem  Everything set here is LOCAL to the window that called it. Nothing changes
rem  your Windows environment permanently, so a broken experiment is always one
rem  closed window away from being fixed, and a Local window can never leak into
rem  a Cloud one.
rem ============================================================================

set "EVIE_MODE=%~1"
if "%EVIE_MODE%"=="" set "EVIE_MODE=cloud"

rem Paths are derived from where THIS file sits, never from a hardcoded folder
rem name. That means the kit works no matter what the cloned folder is called -
rem evie-companion, DarkSide_Studio-Droid-Starter-Kit, or anything else.
set "EVIE_SCRIPTS=%~dp0"
pushd "%~dp0.."    & set "EVIE_REPO=%CD%" & popd
pushd "%~dp0..\.." & set "EVIE_HOME=%CD%" & popd

set "EVIE_VAULT=%EVIE_HOME%\Vault"
set "EVIE_BACKTALK=%EVIE_HOME%\backtalk"
set "EVIE_LOCAL_MODEL=ornith-1.5:9b"

if /i "%EVIE_MODE%"=="local" goto :local_brain

rem ---------------------------------------------------------------- CLOUD ----
rem Clear any local-mode leftovers. If someone once set these permanently, a
rem Cloud window would silently be talking to Ollama and nobody would know why
rem EVIE got worse. This is the fix for that entire class of problem.
set "ANTHROPIC_BASE_URL="
set "ANTHROPIC_AUTH_TOKEN="
set "ANTHROPIC_MODEL="
set "ANTHROPIC_SMALL_FAST_MODEL="
set "ANTHROPIC_DEFAULT_HAIKU_MODEL="
set "ANTHROPIC_DEFAULT_SONNET_MODEL="
set "EVIE_BRAIN_LABEL=Claude (cloud)"
goto :done

rem ---------------------------------------------------------------- LOCAL ----
:local_brain
set "ANTHROPIC_BASE_URL=http://localhost:11434"
set "ANTHROPIC_AUTH_TOKEN=ollama"
set "ANTHROPIC_API_KEY="
set "ANTHROPIC_MODEL=%EVIE_LOCAL_MODEL%"
set "ANTHROPIC_SMALL_FAST_MODEL=%EVIE_LOCAL_MODEL%"
set "ANTHROPIC_DEFAULT_HAIKU_MODEL=%EVIE_LOCAL_MODEL%"
set "ANTHROPIC_DEFAULT_SONNET_MODEL=%EVIE_LOCAL_MODEL%"
set "EVIE_BRAIN_LABEL=%EVIE_LOCAL_MODEL% (local, via Ollama)"

rem --- Read the permanent context setting straight from the registry.
rem     We do NOT set OLLAMA_CONTEXT_LENGTH here: Ollama runs as a background
rem     service and reads its settings when IT starts, not when this window
rem     starts. Setting it here would look like it worked and do nothing.
rem     Reading the registry (rather than %OLLAMA_CONTEXT_LENGTH%) means we see
rem     the true current value even if it was set after this shell opened.
set "EVIE_CTX="
for /f "tokens=2,*" %%a in ('reg query "HKCU\Environment" /v OLLAMA_CONTEXT_LENGTH 2^>nul ^| find "REG_"') do set "EVIE_CTX=%%b"
goto :done

:done
exit /b 0
