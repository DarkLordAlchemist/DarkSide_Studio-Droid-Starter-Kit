@echo off
rem ============================================================================
rem  talk-preflight.cmd - checks shared by both Talk launchers.
rem  Called after evie-env.cmd. Exits 1 (with a plain-English reason) if the
rem  voice cannot start. Does not change any setting.
rem ============================================================================
if not exist "%EVIE_BACKTALK%\pyproject.toml" (
  echo.
  echo   The voice engine is not installed at:
  echo     %EVIE_BACKTALK%
  echo   Fix: open EVIE - Chat ^(Paid^) and say:  "set up my voice"
  echo.
  exit /b 1
)
where uv >nul 2>nul
if errorlevel 1 (
  echo.
  echo   'uv' is not installed. The voice engine needs it.
  echo   Fix: open EVIE - Chat ^(Paid^) and say:  "finish my voice setup"
  echo.
  exit /b 1
)
rem ONE voice window at a time. Two voice sessions fight over the same
rem microphone and speakers; the symptom is a window that "won't take
rem commands", and closing one can take the other down with it.
tasklist /v /fi "imagename eq cmd.exe" 2>nul | findstr /i /c:"EVIE - Talk" | find /c /v "" > "%TEMP%\evie-talk-count.txt"
set /p EVIE_TALKS=<"%TEMP%\evie-talk-count.txt"
del "%TEMP%\evie-talk-count.txt" >nul 2>nul
if %EVIE_TALKS% GTR 1 (
  echo.
  echo   Another EVIE - Talk window is already open. Only one voice session can
  echo   use the microphone at a time. Close the other one, then try again.
  echo.
  exit /b 1
)
exit /b 0
