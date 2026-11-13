@echo off
rem ============================================================================
rem  EVIE - Talk (Paid).  Hold the push-to-talk key, speak, let go.
rem  Press the key again while she is talking to interrupt her.
rem  The microphone is CLOSED except while you hold the key.
rem  To hang up: say "goodbye EVIE", or close this window.
rem ============================================================================
setlocal
title EVIE - Talk (Paid)
call "%~dp0evie-env.cmd" paid
call "%~dp0talk-preflight.cmd"
if errorlevel 1 (pause & exit /b 1)

rem backtalk reads its brain ONLY from backtalk.json, so write it every launch.
rem (A stale local model name left in that file once made the paid voice go
rem silent with no error at all.)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Set-BacktalkModel.ps1" -Model claude-sonnet-5 -DeepModel claude-opus-5 -AgentDir "%EVIE_HOME%"
if errorlevel 1 (echo   Could not update backtalk.json. & pause & exit /b 1)

cd /d "%EVIE_BACKTALK%"
echo.
echo   ==========================================
echo     EVIE - Talk        [ PAID ]
echo   ==========================================
echo     Brain:  %EVIE_BRAIN_LABEL%
echo     Hold the push-to-talk key, speak, then let go.
echo     First launch downloads about 1 GB of voice models. Once only.
echo.
uv sync -q --inexact >nul 2>nul
uv run python -m backtalk.main
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo   Voice session exited with code %RC%. Full log: backtalk\logs\backtalk.log
  echo   "OAuth session expired" in that log means: open EVIE - Chat ^(Paid^)
  echo   and type /login, then relaunch this.
  echo.
  pause
)
endlocal
