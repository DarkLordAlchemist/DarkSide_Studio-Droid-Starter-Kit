@echo off
rem ============================================================================
rem  EVIE - Chat (Paid).  Type to EVIE on Claude, through your subscription.
rem  Needs internet. Use it for anything hard, long, or that you'll rely on.
rem  If your subscription ever lapses, THIS is the only window that will ask
rem  you to sign in - the Local windows never do.
rem  Close the window to end the session.
rem ============================================================================
setlocal
title EVIE - Chat (Paid)
call "%~dp0evie-env.cmd" paid

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
  echo   Fix: run the one-line installer again ^(INSTALL-GUIDE, Step 1^),
  echo   then close EVERY terminal window and try this shortcut again.
  echo.
  pause & exit /b 1
)

echo.
echo   ==========================================
echo     EVIE - Chat        [ PAID ]
echo   ==========================================
echo     Brain:  %EVIE_BRAIN_LABEL%
echo     Vault:  %EVIE_VAULT%
echo.

claude %*
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo   EVIE exited with code %RC%.
  echo   "OAuth session expired" or a login loop means the subscription sign-in
  echo   lapsed: reopen this window and type  /login
  echo   Anything else: reopen and describe it - she reads TROUBLESHOOTING.md.
  echo.
  pause
)
endlocal
