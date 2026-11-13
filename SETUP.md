# SETUP.md — the install wizard

> **AI: this file is addressed to you.** The person who just launched you ran the one-line installer
> (`install.ps1`), so Claude Code, Git and uv are in place and this kit sits at
> `%USERPROFILE%\EVIE\droid-kit`. They may never have used a terminal. You do the install; they answer
> questions. **Read this whole file before you touch anything.**

---

## How to behave during this install

- **One question at a time.** Ask, stop, wait. Never stack questions or answer your own.
- **Plain language.** Any technical word gets a one-line explanation.
- **Report every step honestly.** If something failed, say it failed. Never repair silently and report success.
- **Ask before installing anything.** Name it, say what it's for and roughly how big it is, then wait.
- **Never delete, move or overwrite anything that existed before this session.** If something is
  in the way, rename it `name.backup-YYYY-MM-DD` and say so. The setup script already works this way.
- **Log as you go.** Once the vault exists (Phase 2), every phase gets a `start` and a `done` entry in
  `Vault\log.md` (see the `wiki` skill).
- Tell them up front: **about 30–45 minutes**, plus the offline-brain download if they want it.

---

## Phase 0 — Check the ground (report, don't fix)

Run and report in one short block:

1. `claude --version`, `git --version`, `uv --version`.
2. **Hardware**, for the offline-brain question later:
   `nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv` (it may not exist, which is
   fine), total RAM, and free disk on C:.
3. **Permanent variables that break the paid lane:** check whether `ANTHROPIC_BASE_URL`,
   `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN` or `CLAUDE_CONFIG_DIR` are set in the *User* environment.
   If any are, explain that EVIE sets them per-window on purpose, and offer to remove the permanent copy.
   Ask first.
4. Is there already a `CLAUDE.md` in `%USERPROFILE%\EVIE`? If yes, **stop and ask**. They may already
   have an agent: you adopt it, you don't replace it.
5. Do they already keep notes somewhere (Obsidian vault, a docs folder)? Ask. Pointing the vault at
   what they have beats starting empty.

Then ask permission to continue.

## Phase 1 — The interview

Open `interview/INTERVIEW.md` and work through it **in order, one question at a time**. Do not skip
the guardrails section. Write nothing until it's done, then read the whole picture back in about
eight lines and ask "have I got that right?"

## Phase 2 — Build EVIE's home and memory

Run, from the kit folder:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Setup-EvieHome.ps1
```

Add `-VaultPath "<their existing notes folder>"` if they chose to use one (it's never moved, and it
gets added to the delete-protection list). The script builds `%USERPROFILE%\EVIE\CLAUDE.md`, the vault
as an LLM wiki (`VAULT-INDEX.md` rules, `index.md` catalog, `log.md` timeline, `raw/`, `outputs/`, the
numbered folders), the `wiki` skill, the hooks (delete protection + compaction sweep), and the
Desktop shortcuts. **It never overwrites anything;** read its "kept as-is" list out to them.

Then:

1. Fill every `[FILL IN: ...]` marker in `CLAUDE.md`, `Vault\VAULT-INDEX.md`, `Vault\GUARDRAILS.md`,
   `Vault\Profile.md` and `Vault\Active Priorities.md` from the interview. Write guardrail answers as
   rules, in their words. Delete the AI-facing instruction blocks from the filled copies.
2. Create one folder in `02 - Subjects\` per subject or client they named, each with its own index
   file, and add each one to `Vault\index.md`.
3. Write the first Routine in `04 - Routines\`, from interview question 6 (the time sink).
4. Write `log.md` entries for this phase, then run the vault check and fix what it reports:
   `uv run --no-project python scripts\wiki-lint.py "%USERPROFILE%\EVIE\Vault"`

## Phase 3 — Prove the Paid lane

There are four Desktop shortcuts now. The two Local ones say "not installed yet" until Phase 6.
**Tell them that,** or they'll click one, see the message, and lose confidence in the whole thing.
Confirm `CLAUDE.md` is where `scripts\EVIE-Chat-Paid.bat` expects it (one level above the kit).

## Phase 4 — Voice (ask: now or later?)

"It's about a 1 GB download and needs a microphone." Later is a fine answer. If now:

1. `git clone https://github.com/jaredrhod/backtalk "%USERPROFILE%\EVIE\backtalk"`. Clone it
   **unmodified**. Never copy backtalk's code into the kit (it's AGPL, see CREDITS.md).
2. Follow backtalk's own Windows instructions in its `backtalk.md` (it knows its own dependencies).
3. Copy `config\backtalk.json.example` to `backtalk\backtalk.json` and set `ptt_key` and `voice`
   from the interview. **Leave `model` and `agent_dir` to the launchers:** they rewrite those on
   every start.
4. Explain `permission_mode`: `ask` (she asks out loud before acting) or `bypassPermissions` (she
   just acts, and the guardrails and the delete-protection hook hold the line). Let them choose.
5. Say once: **one voice window at a time** (two fight over the microphone), and **if a voice
   session hangs, close the window and reopen it.** Never end the hidden process by force.

## Phase 5 — First run and handover

1. Create today's daily note from the template, with a short "Setup" entry (what was installed,
   where things live, what was decided).
2. Show three things they can try now, from `USE-CASES.md`, picking ones that will work first time.
3. The two habits: **open Chat and just talk to her,** and **when something breaks, tell her.**
4. Tell them: once the Paid lane works, they can close this window and use **EVIE - Chat (Paid)**.

## Phase 6 — The offline brain: gpt-oss-20b (if they said yes)

Check first: about 16 GB free disk, and say what their hardware means (see `HARDWARE.md`). Under
16 GB of RAM, say plainly that it will be slow or may not load. Then start the installer **in its own
window** (the download is ~12.5 GB, longer than a tool call can wait):

```powershell
Start-Process powershell -ArgumentList '-NoExit','-ExecutionPolicy','Bypass','-File',"$env:USERPROFILE\EVIE\droid-kit\scripts\Install-LocalBrain.ps1"
```

It downloads llama.cpp build **b11871** (the build this kit was tested on) in the right flavour for
their GPU, plus gpt-oss-20b (checked byte for byte). It fits the model to their VRAM and RAM by
loading it for real, times it, **proves tool calling**, seeds the Local lane's own Claude Code
profile, and **proves Claude Code can run a tool through it with no sign-in**. Wait for
`%USERPROFILE%\EVIE\local\install-status.json` to show `"state": "ok"` (check it every few minutes,
and tell them it's normal for this to take a while). Then:

1. Read the result out in plain words: speed, context size, and whether both proofs passed. Under 8
   tokens/sec, say directly that Local is for short jobs and real work belongs in Paid.
2. If `state` is `ok-with-warnings` or `failed`, read `TROUBLESHOOTING.md` → *Local brain* and fix it
   before handing over.
3. Have them open **EVIE - Chat (Local)** and run the four tests in `GOING-LOCAL.md`. Write the
   results as a vault note, add it to `index.md`, and log it.

**Why the Local lane never asks for a sign-in:** its windows point Claude Code at a separate profile
(`EVIE\local\claude-profile`) that has never been logged in, with a local token. A lapsed subscription
only ever affects the Paid shortcuts.

---

## What not to do

- Don't set permanent Windows environment variables. Everything is per-window in
  `scripts\evie-env.cmd`, and the local brain's settings are in `EVIE\local\brain.cmd`.
- Don't hand-edit `EVIE\local\brain.cmd` to "make it faster" without re-running the installer. It
  measured the fit.
- Don't add MCP servers or connectors to the Local lane. gpt-oss's chat template crashes on some
  of their nested tool schemas.
- Don't put the EVIE folder in OneDrive, Documents or Desktop. Sync services and agents fight over
  file locks.
- Don't install the visualizer or barehands. They're not in scope here.
