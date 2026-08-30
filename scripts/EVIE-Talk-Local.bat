@echo off
rem ============================================================================
rem  EVIE - Talk (Local).  Voice, running entirely on your own machine.
rem  Hearing, thinking, and speaking all happen here. No internet at all.
rem
rem  The microphone is CLOSED except while you hold the key.
rem  Ctrl+C in this window ends the session.
rem ============================================================================
setlocal
title EVIE - Talk (Local)
call "%~dp0evie-env.cmd" local

if not exist "%EVIE_BACKTALK%\pyproject.toml" (
  echo.
  echo   The voice engine is not installed at:
  echo     %EVIE_BACKTALK%
  echo   Fix: open EVIE - Chat ^(Cloud^) and say:  "set up my voice"
  echo.
  pause & exit /b 1
)

where uv >nul 2>nul
if errorlevel 1 (
  echo.
  echo   'uv' is not installed. The voice engine needs it.
  echo   Fix: open EVIE - Chat ^(Cloud^) and say:  "finish my voice setup"
  echo.
  pause & exit /b 1
)

cd /d "%EVIE_BACKTALK%"

where ollama >nul 2>nul
if errorlevel 1 (
  echo.
  echo   Ollama is not installed, so there is no local brain to talk to.
  echo   Use EVIE - Talk ^(Cloud^) instead.
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
  echo   WARNING: OLLAMA_CONTEXT_LENGTH is not set. Run
  echo   scripts\Set-OllamaTuning.ps1 first or she will lose the thread.
  echo.
  timeout /t 10 >nul
  set "EVIE_CTX=(not set)"
)

echo.
echo   ==========================================
echo     EVIE - Talk        [ LOCAL ]
echo   ==========================================
echo     Brain:    %EVIE_BRAIN_LABEL%
echo     Context:  %EVIE_CTX% tokens
echo.
echo     Fully offline. Expect a longer pause before she answers than
echo     in Cloud - the whole model is running on this laptop.
echo.

uv run python -m backtalk.main
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo   Voice session exited with code %RC%.
  echo   If it keeps failing, try EVIE - Talk ^(Cloud^) - that tells you
  echo   whether the problem is the voice setup or the local model.
  echo.
  pause
)
endlocal
