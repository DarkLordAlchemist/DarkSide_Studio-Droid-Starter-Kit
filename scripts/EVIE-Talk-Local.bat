@echo off
rem ============================================================================
rem  EVIE - Talk (Local).  Voice on gpt-oss-20b. Hearing, thinking and speaking
rem  all happen on this machine. No internet, no subscription, no sign-in.
rem  Hold the push-to-talk key, speak, let go. The mic is CLOSED otherwise.
rem  To hang up: say "goodbye EVIE", or close this window.
rem ============================================================================
setlocal
title EVIE - Talk (Local)
call "%~dp0evie-env.cmd" local
if defined EVIE_LOCAL_MISSING (
  echo.
  echo   The local brain is not installed yet. Open EVIE - Chat ^(Paid^) and
  echo   say "install my local brain", or run scripts\Install-LocalBrain.ps1.
  echo.
  pause & exit /b 1
)
call "%~dp0talk-preflight.cmd"
if errorlevel 1 (pause & exit /b 1)

call "%~dp0start-local-brain.cmd"
if errorlevel 1 (echo   The local brain did not start - see above. & pause & exit /b 1)

rem Same reason as the Paid launcher: backtalk reads its brain only from
rem backtalk.json. The voice engine inherits this window's CLAUDE_CONFIG_DIR, so
rem it also runs on the sealed local profile and never asks you to sign in.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Set-BacktalkModel.ps1" -Model %EVIE_LLM_ALIAS% -DeepModel %EVIE_LLM_ALIAS% -AgentDir "%EVIE_HOME%"
if errorlevel 1 (echo   Could not update backtalk.json. & pause & exit /b 1)

cd /d "%EVIE_BACKTALK%"
echo.
echo   ==========================================
echo     EVIE - Talk        [ LOCAL ]
echo   ==========================================
echo     Brain:  %EVIE_BRAIN_LABEL%
echo     Fully offline. Expect a longer pause before she answers than in Paid.
echo.
uv sync -q --inexact >nul 2>nul
uv run python -m backtalk.main
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo   Voice session exited with code %RC%. Full log: backtalk\logs\backtalk.log
  echo   If it keeps failing, try EVIE - Talk ^(Paid^): that tells you whether the
  echo   problem is the voice setup or the local model.
  echo.
  pause
)
endlocal
