# Troubleshooting

> **AI:** this file is written for you as much as for the person. If they open EVIE - Chat and
> describe a problem, read this, diagnose it, and fix it. Don't hand the problem back to them. If a
> fix means deleting or installing something, say what and wait for a yes.
>
> Every entry below is a failure that actually happened while this kit was being built, and the
> fix that worked.

---

## Install and launch

**`claude` is not recognized**
The window was opened before Claude Code was installed. `install.ps1` refreshes PATH itself, but any
*other* window opened earlier won't see it. Close every terminal, open a new one, and retry. The
program lives at `%USERPROFILE%\.local\bin`. `claude doctor` prints a diagnosis.

**The login browser loops, or says the account isn't eligible**
Claude Code needs a Pro, Max, Team, Enterprise or Console account. The free plan doesn't include it.
It's usually the wrong account in the browser.

**An EVIE window flashes and disappears**
Run the launcher from a terminal so the error stays on screen: open PowerShell in
`EVIE\droid-kit\scripts` and run `.\EVIE-Chat-Paid.bat`. Nearly always, the EVIE folder was moved, or
`CLAUDE.md` is missing one level above the kit.

**"The system cannot find the batch label specified" / a launcher acts strangely after an edit**
The `.bat` file lost its Windows line endings (CRLF). That happens when it's edited with a Unix-style
tool. `.gitattributes` keeps them right on download. To repair one, re-download it, or ask EVIE to
convert it back to CRLF.

**A launcher run from inside a Claude session just shows a blank Windows banner**
Shell quoting swallowed the command. Double-click the Desktop shortcut instead. That always works.

---

## Paid lane

**"OAuth session expired" / the voice won't start / a crash loop in the Talk (Paid) window**
The subscription sign-in lapsed. Open **EVIE - Chat (Paid)**, type `/login`, sign in, and relaunch.
This only ever affects Paid: the Local lane uses its own never-signed-in profile.

**Paid suddenly acts like the local model, or complains about credentials**
A *permanent* `ANTHROPIC_BASE_URL`, `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN` or `CLAUDE_CONFIG_DIR`
is set in the Windows user environment. The launchers clear these per-window, so this happens when
`claude` is started directly instead of through a shortcut, or when something outside EVIE set them.
Check:

```powershell
'ANTHROPIC_BASE_URL','ANTHROPIC_API_KEY','ANTHROPIC_AUTH_TOKEN','CLAUDE_CONFIG_DIR' | % { "$_ = " + [Environment]::GetEnvironmentVariable($_,'User') }
```

Remove any that are set (ask first): `[Environment]::SetEnvironmentVariable('NAME', $null, 'User')`.
Nothing in this kit ever sets them permanently.

---

## Local brain (gpt-oss-20b)

**A Local shortcut says "the local brain is not installed yet"**
Run `scripts\Install-LocalBrain.ps1` (or say "install my local brain" in Chat (Paid)).

**The local brain "never became ready"**
Open the minimised *EVIE local brain* window and read the last lines. Out of memory means too much is
on the GPU: re-run `Install-LocalBrain.ps1`, which re-measures, or add `-NCpuMoe` with a higher number.
"Address in use" means another program has port 8085: re-run with `-Port 8095`.

**It asks me to sign in to Anthropic in a Local window**
This should never happen. It means the window isn't using the sealed profile. Check that
`EVIE\local\claude-profile\` exists and that `EVIE\local\brain.cmd` exists, and only launch Local through
the shortcut. Re-running `Install-LocalBrain.ps1` re-creates the profile.

**HTTP 500 with `param_spec.type` in the error**
gpt-oss's chat template crashed on a complicated tool schema from an MCP server or connector. The
Local launcher blocks those with `--strict-mcp-config`. If you added one by hand, remove it.

**She says she has no tools, or can't see a tool she should have**
The Local launcher has to *name* every tool. Leaving `--tools` out gave a session with zero usable
tools, and `--tools default` silently drops anything from MCP. Use the shortcut, not a hand-typed
`claude` command.

**She gives a strange excuse ("system policy", "auto-mode") for not doing something**
On a local model, a session silently waiting on an approval prompt makes up a reason instead of
saying so. The Local launcher runs with `--permission-mode bypassPermissions` for exactly this
reason. The guardrails and the delete-protection hook hold the line instead.

**She opened Excel/Word and everything froze**
A window app was launched in the foreground, so the tool call waits for it to close, forever. Close
the app, or close and reopen the EVIE window. The rule in `CLAUDE.md` ("always `start` window apps")
prevents it. Remind her of it.

**She loses the thread halfway through, or answers start failing on long sessions**
The conversation outgrew the context. Claude Code doesn't know gpt-oss's real window, so the
launcher sets auto-compaction to about 80% of the real size (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` in
`brain.cmd`). The old `CLAUDE_CODE_MAX_CONTEXT_TOKENS` setting is ignored for custom models. Don't
rely on it. Start fresh sessions more often on Local.

**Painfully slow**
Check the speed the installer measured (`install-status.json`). Then, in order: close your browser
(it holds VRAM); make sure no other model is loaded (only one fits); re-run `Install-LocalBrain.ps1`;
and keep heavy work in Paid. If Windows is short on RAM it can evict the part of the model kept in
RAM. The launcher's large batch settings (`-b/-ub 2048`) soften that, but more RAM is the real fix.

**Two models, or a crash when switching**
The GPU holds one model at a time. The Local launcher stops any other `llama-server` before loading
gpt-oss. If something else keeps restarting one, close that program.

---

## Memory (the vault)

**She doesn't remember anything about me**
In order: does `CLAUDE.md` exist in the folder the shortcut opens? Does the vault path inside it
exist? Do `Vault\VAULT-INDEX.md` and `Vault\index.md` exist? Most "amnesia" is one wrong path.

**She remembers the wrong or stale things**
Ask for a lint: "check the vault". She runs `scripts\wiki-lint.py`, then a judgment pass that merges
duplicates, marks outdated claims and fixes the index.

**She forgot mid-task**
Context compaction. `CLAUDE.md` survives it; vault files don't. A hook reminds her to re-read the
rules and save surviving lessons right after compaction, and a marker lands in `log.md`. If it
happens often, sessions are too long: start fresh ones.

**A delete or move command stops and asks for approval**
That's the delete-protection hook doing its job: anything that deletes or moves files inside the
EVIE folder (or a folder in `.claude\protected-paths.txt`) needs your yes. Approve only if you meant
it. The hook reads the command text, so it can't see deletes inside a script file being run. The
guardrails still apply there.

---

## Voice

**No sound**
Check Windows sound output first, then the Talk window for an error. The voice packages bundle
espeak-ng, so you don't need a separate system install.

**She can't hear me**
The mic only opens while the push-to-talk key is held. If the key does nothing, another program has
grabbed it, so pick a different `ptt_key` in `backtalk.json`.

**A Talk window won't take commands, or closing one killed another**
Two voice sessions were open at once and fought over the microphone and speakers. The Talk
launchers now refuse to start a second one. Use one voice window at a time.

**The voice went silent with no error, after using a different model**
`backtalk.json` still named a model from another session. The Talk launchers now rewrite `model`
and `agent_dir` on every start, so relaunching through the shortcut fixes it.

**Right after a hang was "fixed", the next thing I said vanished**
The hidden `claude` process was force-killed from outside (Task Manager, `Stop-Process`). That leaves
the voice engine's connection silently dead, and the next utterance is lost. **Never force-kill it.**
Close the Talk window and reopen the shortcut.

**Voice EVIE doesn't act like Chat EVIE**
`agent_dir` must point at the folder holding `CLAUDE.md`. The launchers set it every start. If you
launched backtalk by hand, use the shortcut instead.

**She reads out "asterisk" or "hash"**
She formatted a spoken reply. The rule in `CLAUDE.md` says plain sentences only in voice. Say
"plain sentences, you're on voice", and she should hold to it.

**The session dies the moment she opens an image**
Claude Code's message reader has a hard 1 MB limit, and anything bigger kills the session with no
error. Keep images small (resize screenshots), and don't ask her to open huge files directly.

---

## When none of this helps

Open EVIE - Chat (Paid) and describe what you saw, what you expected, and what you'd already tried.
She can read this file and her own configuration, run diagnostics, and fix it. That's the intended
workflow, not a last resort.
