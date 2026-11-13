@echo off
rem ============================================================================
rem  EVIE - Chat (Local).  Type to EVIE running on gpt-oss-20b, on THIS machine.
rem  No internet, no subscription, no sign-in - ever.
rem  Slower and less capable than Paid; see USE-CASES.md for what holds up.
rem  Close the window to end the session. The minimised "EVIE local brain"
rem  window is the model itself: leave it open while you work.
rem ============================================================================
setlocal
title EVIE - Chat (Local)
call "%~dp0evie-env.cmd" local

if defined EVIE_LOCAL_MISSING (
  echo.
  echo   The local brain is not installed yet.
  echo   Open EVIE - Chat ^(Paid^) and say:  "install my local brain"
  echo   or run scripts\Install-LocalBrain.ps1 yourself.
  echo.
  pause & exit /b 1
)

cd /d "%EVIE_HOME%"
if not exist "%EVIE_HOME%\CLAUDE.md" (
  echo.
  echo   Cannot find CLAUDE.md in %EVIE_HOME% - setup did not finish, or the
  echo   EVIE folder was moved. Move it back, or rerun setup from Paid.
  echo.
  pause & exit /b 1
)

where claude >nul 2>nul
if errorlevel 1 (
  echo.
  echo   Claude Code is not installed, or Windows cannot find it.
  echo   Close EVERY terminal window and try again.
  echo.
  pause & exit /b 1
)

call "%~dp0start-local-brain.cmd"
if errorlevel 1 (
  echo.
  echo   The local brain did not start - see the message above.
  pause & exit /b 1
)

echo.
echo   ==========================================
echo     EVIE - Chat        [ LOCAL ]
echo   ==========================================
echo     Brain:  %EVIE_BRAIN_LABEL%
echo     Vault:  %EVIE_VAULT%
echo.
echo     Offline. She cannot search the web or know recent events here.
echo.

rem Why this exact command line - every flag is a fix for a real failure:
rem  --tools <list>    Name the tools explicitly. Leaving --tools out gave a
rem                    session with ZERO usable tools; --tools default skips
rem                    anything from MCP. WebSearch is left out on purpose: it
rem                    is an Anthropic server feature and cannot work offline.
rem  --strict-mcp-config  No MCP servers or connectors at all. gpt-oss's chat
rem                    template crashes (HTTP 500, "param_spec.type") on the
rem                    deeply nested schemas some connectors send.
rem  --permission-mode bypassPermissions  With approval prompts on, a local
rem                    model that is silently waiting on one invents a fake
rem                    reason ("system policy") instead of saying so. The
rem                    guardrails in CLAUDE.md plus the delete-protection hook
rem                    in .claude\settings.json hold the line instead.
claude --model %EVIE_LLM_ALIAS% --tools Read,Write,Edit,Bash,Glob,Grep,WebFetch,TodoWrite --strict-mcp-config --permission-mode bypassPermissions %*
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo   EVIE exited with code %RC%.
  echo   If local keeps failing, try the same task in Paid - that tells you
  echo   instantly whether it is the model or the setup.
  echo.
  pause
)
endlocal
