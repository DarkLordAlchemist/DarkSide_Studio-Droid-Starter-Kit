@echo off
rem ============================================================================
rem  EVIE - Talk (Cloud).  Hold the push-to-talk key, speak, let go.
rem  Press the key again while she is talking to interrupt her.
rem  Ctrl+C in this window ends the session.
rem
rem  The microphone is CLOSED except while you hold the key. Nothing is
rem  recorded in the background, ever.
rem ============================================================================
setlocal
title EVIE - Talk (Cloud)
call "%~dp0evie-env.cmd" cloud

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

echo.
echo   ==========================================
echo     EVIE - Talk        [ CLOUD ]
echo   ==========================================
echo     Brain:  %EVIE_BRAIN_LABEL%
echo.
echo     Hold the push-to-talk key, speak, then let go.
echo     First launch downloads about 1 GB of voice models. Once only.
echo.

uv run python -m backtalk.main
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo   Voice session exited with code %RC%.
  echo   Reopen EVIE - Chat ^(Cloud^) and describe what happened.
  echo.
  pause
)
endlocal
