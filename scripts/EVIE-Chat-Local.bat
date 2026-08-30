@echo off
rem ============================================================================
rem  EVIE - Chat (Local).  Type to EVIE, running on your own machine.
rem  No internet needed. Slower and less capable than Cloud - see USE-CASES.md
rem  for which tasks hold up here.
rem  Close the window to end the session.
rem ============================================================================
setlocal
title EVIE - Chat (Local)
call "%~dp0evie-env.cmd" local

cd /d "%EVIE_HOME%"
if not exist "%EVIE_HOME%\CLAUDE.md" (
  echo.
  echo   Cannot find CLAUDE.md in %EVIE_HOME%
  echo   Setup did not finish, or the EVIE folder was moved or renamed.
  echo   Fix: open PowerShell in %EVIE_REPO% and run:
  echo        claude "read SETUP.md and set me up"
  echo.
  pause & exit /b 1
)

where claude >nul 2>nul
if errorlevel 1 (
  echo.
  echo   Claude Code is not installed, or Windows cannot find it.
  echo   Fix: open PowerShell and run:   irm https://claude.ai/install.ps1 ^| iex
  echo   Then close EVERY terminal window and try this shortcut again.
  echo.
  pause & exit /b 1
)

where ollama >nul 2>nul
if errorlevel 1 (
  echo.
  echo   Ollama is not installed, so there is no local brain to talk to.
  echo   Use the Cloud shortcut instead, or set up local mode:
  echo   open EVIE - Chat ^(Cloud^) and say "set me up for local mode".
  echo.
  pause & exit /b 1
)

curl -s -o nul -m 5 http://localhost:11434/api/version
if errorlevel 1 (
  echo.
  echo   Ollama is installed but not responding on port 11434.
  echo   Fix: start Ollama from the Start menu, wait ten seconds, try again.
  echo.
  pause & exit /b 1
)

if "%EVIE_CTX%"=="" (
  echo.
  echo   WARNING: OLLAMA_CONTEXT_LENGTH is not set.
  echo   EVIE will lose track of what she is doing partway through tasks.
  echo   Fix: right-click scripts\Set-OllamaTuning.ps1 and choose
  echo        "Run with PowerShell". It takes about a minute.
  echo.
  echo   Continuing anyway in 10 seconds. Ctrl+C to stop.
  timeout /t 10 >nul
  set "EVIE_CTX=(not set)"
)

echo.
echo   ==========================================
echo     EVIE - Chat        [ LOCAL ]
echo   ==========================================
echo     Brain:    %EVIE_BRAIN_LABEL%
echo     Context:  %EVIE_CTX% tokens
echo     Vault:    %EVIE_VAULT%
echo.
echo     No internet needed. She cannot search the web or look up
echo     anything recent in this mode.
echo.

claude
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo   EVIE exited with code %RC%.
  echo   If local mode keeps failing, try the same task in Cloud - that tells
  echo   you instantly whether it is the model or the setup.
  echo.
  pause
)
endlocal
