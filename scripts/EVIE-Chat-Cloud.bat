@echo off
rem ============================================================================
rem  EVIE - Chat (Cloud).  Type to EVIE, running on Claude. Needs internet.
rem  This is the one to use for anything hard, long, or that you'll rely on.
rem  Close the window to end the session.
rem ============================================================================
setlocal
title EVIE - Chat (Cloud)
call "%~dp0evie-env.cmd" cloud

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

echo.
echo   ==========================================
echo     EVIE - Chat        [ CLOUD ]
echo   ==========================================
echo     Brain:  %EVIE_BRAIN_LABEL%
echo     Vault:  %EVIE_VAULT%
echo.

claude
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo   EVIE exited with code %RC%.
  echo   If that was unexpected, reopen this window and describe what happened -
  echo   she can read TROUBLESHOOTING.md and fix most things herself.
  echo.
  pause
)
endlocal
