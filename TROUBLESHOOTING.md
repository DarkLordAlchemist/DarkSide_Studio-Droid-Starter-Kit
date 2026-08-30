# Troubleshooting

> **AI:** this file is written for you as much as for the person. If they open EVIE — Chat and
> describe a problem, read this, diagnose it, and fix it. Do not hand the problem back to them.
> If a fix requires deleting or installing something, say what and wait for a yes.

---

## Install and launch

**`claude` is not recognized / command not found**

The terminal was open before Claude Code was installed. Close every terminal window, open a new
PowerShell, retry. If it persists, `claude doctor` prints a diagnosis. The binary lives at
`%USERPROFILE%\.local\bin` — confirm that folder is on PATH.

**The login browser loops, or says the account isn't eligible**

Claude Code needs a Pro, Max, Team, Enterprise, or Console account. The free plan does not include
it. Check which account the browser is logged into — this is usually a wrong-account problem, not a
subscription problem.

**An EVIE window flashes and disappears**

The batch file couldn't find something and the error scrolled past. Open PowerShell, `cd` to the
`scripts` folder, and run the launcher from there — e.g. `.\EVIE-Chat-Cloud.bat` — so the error stays
on screen. Nearly always either the `EVIE` folder was moved or `CLAUDE.md` is missing.

**The Local shortcuts don't work but Cloud does**

Expected if you haven't done Phase 2. The Local launchers check for Ollama and refuse to start
without it. See GOING-LOCAL.md.

**"Cannot find CLAUDE.md"**

The folder layout changed. The batch files expect:
`<anything>\EVIE\<kit-folder>\scripts\EVIE-Chat-Cloud.bat`, with `CLAUDE.md` sitting one level up
in the `EVIE` folder. The kit folder can be called anything; the level it sits at is what matters.
Move it back, or open a Claude Code session in the EVIE folder and say "my paths are wrong, fix the
batch files."

---

## Memory and vault

**She doesn't remember anything about me**

In order: (1) does `CLAUDE.md` exist in the working directory the shortcut opens? (2) does the vault
path inside it point at a folder that actually exists? (3) does `VAULT-INDEX.md` exist at the vault
root? Most "amnesia" is one wrong path.

**She remembers, but the wrong things / stale things**

The vault drifted. Ask her to audit it: "read VAULT-INDEX.md and every folder index, and tell me
what's out of sync with what's actually on disk." Then have her fix it in one pass.

**Notes are going in the wrong folders**

The folder indexes are stale or the structure section of `VAULT-INDEX.md` doesn't match reality.
Fix the map, not the individual note.

**She forgot mid-task**

Context compaction. `CLAUDE.md` survives it; `VAULT-INDEX.md` does not. If this happens often, the
sessions are too long — start fresh ones more often, and make sure she's checkpointing to the vault
as she goes rather than holding everything in the conversation.

---

## Voice

**No sound comes out**

Check Windows sound output first, then check the terminal for an espeak-ng error. The voice engine
needs espeak-ng installed natively on Windows; if it's missing, reinstall it via backtalk's own
wizard rather than by hand.

**She can't hear me**

The mic only opens while the push-to-talk key is held. Confirm you're holding it, and check Windows
sound input to see the level move. If the key does nothing, another program has grabbed it — pick a
different `ptt_key` in `backtalk.json`.

**Voice EVIE doesn't act like Chat EVIE**

`agent_dir` in `backtalk.json` isn't pointing at the folder containing `CLAUDE.md`. That path is the
entire link between the voice and her identity. Absolute path, doubled backslashes.

**First launch is very slow**

It's downloading about 1 GB of speech and voice models. Once only.

**She talks over herself / repeats**

Interrupt with the push-to-talk key. If it's constant, the thinking-sound or the model is looping —
restart the window.

---

## Local mode (Ollama)

**A Local shortcut says Ollama isn't installed**

It isn't. Use a Cloud shortcut, or follow GOING-LOCAL.md.

**Connection refused on localhost:11434**

Ollama isn't running. Start it from the Start menu; check the system tray. Verify with
`ollama list` in PowerShell.

**The Local window says "OLLAMA_CONTEXT_LENGTH is not set"**

Right-click `scripts\Set-OllamaTuning.ps1` → **Run with PowerShell**. Takes about a minute. It picks
the right value for your hardware and verifies it.

**She loses the thread halfway through tasks**

Context length. Run `Set-OllamaTuning.ps1`. If it's already been run and this still happens, the
machine can't sustain a big enough window — the script's own output will have told you the number it
settled on. Under 32K, keep local sessions short and do multi-step work in Cloud.

**Painfully slow generation**

The model is spilling out of VRAM into system RAM. Run `ollama ps` — a CPU percentage confirms it.
In order: close your browser, then
`.\Set-OllamaTuning.ps1 -Context 16384`, then set `OLLAMA_KV_CACHE_TYPE` to `q4_0`, then use a
smaller model.

**She picks the wrong tool and loops**

The Anthropic compatibility layer ignores `tool_choice`. Ctrl+C, rephrase more explicitly, or do that
task in cloud mode. Not fixable from this end.

**Cloud suddenly acts local, or complains about credentials**

Almost always a leftover permanent `ANTHROPIC_BASE_URL` or `ANTHROPIC_API_KEY`. The Cloud launchers
clear these inside their own window, so if you're seeing this you either launched `claude` directly
instead of through a shortcut, or something outside EVIE set them. Check with:

```powershell
[Environment]::GetEnvironmentVariable('ANTHROPIC_BASE_URL','User')
```

If that returns anything, remove it:

```powershell
[Environment]::SetEnvironmentVariable('ANTHROPIC_BASE_URL', $null, 'User')
```

Nothing in this repo ever sets those permanently, by design.

---

## When none of this helps

Open EVIE — Chat and describe what you saw, what you expected, and what you'd already tried. She can
read this file, read her own configuration, run diagnostics, and fix it. That is the intended
workflow, not a last resort.
