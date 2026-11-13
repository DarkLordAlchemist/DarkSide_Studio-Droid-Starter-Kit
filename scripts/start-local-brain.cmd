@echo off
rem ============================================================================
rem  start-local-brain.cmd - make sure gpt-oss-20b is being served by llama.cpp
rem  Called by the Local launchers after evie-env.cmd local. Safe to call twice:
rem  if the brain already answers, it does nothing.
rem
rem  Why llama.cpp and not Ollama: llama.cpp's server speaks Claude Code's own
rem  API (/v1/messages) and runs gpt-oss's tool-call format natively (--jinja),
rem  and --n-cpu-moe lets a 20B model run on an 8 GB card by parking some of its
rem  "experts" in RAM. Measured on an RTX 5070 Laptop: ~22 tokens/sec.
rem ============================================================================
setlocal
if not exist "%EVIE_LLAMA%\llama-server.exe" (
  echo   local brain: llama.cpp is not installed. Run scripts\Install-LocalBrain.ps1
  exit /b 1
)
if not exist "%EVIE_GGUF%" (
  echo   local brain: the model file is missing:
  echo     %EVIE_GGUF%
  echo   Run scripts\Install-LocalBrain.ps1 to download it.
  exit /b 1
)

call :health
if not errorlevel 1 (
  echo   local brain: already running.
  exit /b 0
)

rem The GPU holds one model at a time. Stop any other llama-server first - two
rem models fighting for VRAM is a crash, not a slowdown.
tasklist /fi "imagename eq llama-server.exe" | find /i "llama-server.exe" >nul
if not errorlevel 1 (
  echo   local brain: stopping another llama-server so gpt-oss fits in VRAM . . .
  taskkill /f /im llama-server.exe >nul 2>nul
  ping -n 4 127.0.0.1 >nul
)

echo   local brain: loading gpt-oss-20b . . . the first load takes a minute or two.
rem -b/-ub 2048: bigger prompt batches. Under RAM pressure Windows can evict the
rem   memory-mapped experts; bigger passes make re-reading them cheaper.
rem -ctk/-ctv q8_0: halves the context cache's memory for no visible quality cost.
rem --jinja: gpt-oss's own chat template, which is what makes tool calls work.
start "EVIE local brain (llama.cpp - leave open)" /min "%EVIE_LLAMA%\llama-server.exe" -m "%EVIE_GGUF%" --host 127.0.0.1 --port %EVIE_LLM_PORT% -c %EVIE_LLM_CTX% -np 1 -ngl %EVIE_NGL% -fa on -ctk q8_0 -ctv q8_0 --n-cpu-moe %EVIE_NCPUMOE% -b 2048 -ub 2048 --jinja --alias %EVIE_LLM_ALIAS%

set /a N=0
:wait
call :health
if not errorlevel 1 (
  echo   local brain: ready.
  exit /b 0
)
set /a N+=1
if %N% GEQ 600 (
  echo   local brain: it never became ready. Open the minimised
  echo   "EVIE local brain" window to read the real error.
  exit /b 1
)
rem ping, not timeout: timeout fails instantly when there is no console
rem ("Input redirection is not supported") and the loop would spin.
ping -n 2 127.0.0.1 >nul
goto :wait

:health
curl -s -m 5 http://127.0.0.1:%EVIE_LLM_PORT%/health 2>nul | findstr /c:"ok" >nul 2>nul
exit /b %errorlevel%
