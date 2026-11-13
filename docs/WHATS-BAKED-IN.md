# What's baked in: every past problem, and where the kit now handles it

These are real failures hit while building and running this setup, and each fix ships in the kit.
Nothing here needs to be done by hand.

| # | The problem that actually happened | What the kit does now | Where |
|---|---|---|---|
| 1 | "`claude` is not recognized" right after installing (the window predated the install) | The installer refreshes PATH in its own window before using anything it installed | `install.ps1` |
| 2 | A permanent `ANTHROPIC_BASE_URL` made the paid brain silently talk to a local model | Every window clears all brain settings first; nothing is ever set permanently; the installer warns if one exists | `evie-env.cmd`, `install.ps1` |
| 3 | A lapsed subscription brought back the sign-in screen everywhere | The Local lane uses its own sealed Claude Code profile (`CLAUDE_CONFIG_DIR`) with a local token, so it **never** asks for a sign-in. Only Paid can | `evie-env.cmd`, `Install-LocalBrain.ps1` step 7 |
| 4 | "OAuth session expired" crash loop in the voice | The Paid launchers say exactly what to do: type `/login` in Chat (Paid) | `EVIE-*-Paid.bat`, TROUBLESHOOTING |
| 5 | gpt-oss's chat template crashed (HTTP 500, `param_spec.type`) on complicated connector/MCP schemas | Local runs with no MCP servers or connectors (`--strict-mcp-config`) and a sealed profile that has none | `EVIE-Chat-Local.bat` |
| 6 | Leaving `--tools` out gave ZERO usable tools; `--tools default` silently dropped MCP tools | The Local launcher names every tool explicitly | `EVIE-Chat-Local.bat` |
| 7 | A local model silently waiting on an approval prompt made up excuses ("system policy") | Local runs with `bypassPermissions`; the guardrails and the delete-protection hook hold the line | `EVIE-Chat-Local.bat`, hooks |
| 8 | Tool calling has to actually work on the local brain | The installer **proves** it twice: gpt-oss calls a test tool correctly, and Claude Code runs a real Bash tool through it | `Install-LocalBrain.ps1` steps 6–7 |
| 9 | Context overflow looked like a hang; `CLAUDE_CODE_MAX_CONTEXT_TOKENS` is ignored for custom models | Auto-compaction set to ~80% of the *real* context via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`, calculated per machine | `Install-LocalBrain.ps1`, `brain.cmd` |
| 10 | Two models fighting over an 8 GB GPU | The Local launcher stops any other llama-server before loading gpt-oss | `start-local-brain.cmd` |
| 11 | Model too big for the card; guessing settings | The installer **loads the model for real**, needs 500 MB of VRAM spare, and backs off until it fits | `Install-LocalBrain.ps1` step 4 |
| 12 | Under RAM pressure Windows evicted the part of the model kept in RAM | Large prompt batches (`-b/-ub 2048`) so re-reads are cheap; 16 GB RAM floor stated up front | `start-local-brain.cmd`, HARDWARE |
| 13 | Opening Excel/Word in the foreground froze the session forever | Hard rule in EVIE's boot file: always `start` window apps so they detach | `templates/CLAUDE.md` |
| 14 | The voice read markdown out loud ("asterisk asterisk") | Hard rule: plain sentences only in voice, with a scan-before-sending check | `templates/CLAUDE.md` |
| 15 | A stale model name in `backtalk.json` made the voice go silent with no error | The Talk launchers rewrite `model` and `agent_dir` on every start | `Set-BacktalkModel.ps1` |
| 16 | Two voice windows fought over the microphone; closing one killed the other | The Talk launchers refuse to open a second voice window | `talk-preflight.cmd` |
| 17 | Force-killing a hung process made the next spoken command vanish | Documented rule, repeated in the boot file: close and reopen the window, never force-kill | `templates/CLAUDE.md`, TROUBLESHOOTING |
| 18 | Opening an image over 1 MB killed the session with no error | Rule in the boot file: don't open large images directly; resize first | `templates/CLAUDE.md` |
| 19 | `.bat` files edited with Unix tools broke on `goto` (line endings) | `.gitattributes` forces CRLF; the troubleshooting entry explains the repair | `.gitattributes` |
| 20 | `evie-env.cmd` computed the EVIE folder from the *caller's* folder (batch expands `%CD%` too early) | Fixed with `for %%I … %%~fI`, tested from several starting folders | `evie-env.cmd` |
| 21 | Accidental deletes by an agent with disk access | A PreToolUse hook pauses any delete or move inside EVIE's folder until you approve | `scripts/hooks/protect-delete.ps1` |
| 22 | Lessons lost when a long conversation got compressed | A PreCompact hook marks the log, and a post-compaction hook makes EVIE re-read her rules and save surviving lessons | `scripts/hooks/` |
| 23 | Memory sprawl: duplicates, stale claims, giant files | An LLM-wiki vault: index, append-only log, provenance tags, "early signal" and outdated labels, a memory-write filter, small pages, and a lint with a sleep pass | `templates/`, `wiki-lint.py`, wiki skill |
| 24 | Setup overwriting an existing agent or notes | The setup script never overwrites; it adopts an existing notes folder in place and protects it | `Setup-EvieHome.ps1` |
| 25 | Console garbled UTF-8 from Python tools | `PYTHONUTF8=1` set per window | `evie-env.cmd` |
