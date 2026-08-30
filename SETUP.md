# SETUP.md — the install wizard

> **AI: this file is addressed to you.** The person who just launched you has never done this before
> and may have never used a terminal. You are doing the install; they are answering questions.
>
> Read this whole file before you touch anything.

---

## How to behave during this install

- **One question at a time.** Ask it, stop, wait for the answer. Do not stack questions. Do not
  answer your own question and keep going.
- **Plain language.** No jargon without a one-line explanation. "PATH" means nothing to them.
- **Never assume a path.** Check that folders exist before writing to them.
- **Report every step honestly.** If something failed, say it failed. Do not repair silently and
  report success.
- **Ask before installing anything.** Name it, say what it's for, say roughly how big it is, wait.
- **Never delete or overwrite anything you didn't create in this session.** If a file is in your way,
  rename it with a `.backup-YYYY-MM-DD` suffix and say so.
- **This install should take 20–40 minutes** including the interview. Tell them that up front.

---

## Phase 0 — Check the ground

Run these and report the results in one short block. Don't fix anything yet.

1. `claude --version` — should print a version number.
2. Is there an existing `CLAUDE.md` anywhere in the parent folder? If yes, **stop and ask.** They may
   already have an agent. You adopt it, you don't replace it.
3. Is there an existing Obsidian vault or notes folder? Ask before creating a new one — pointing EVIE
   at notes they already have is better than starting empty.
4. `git --version` — if missing, offer to install Git for Windows and explain in one line that it
   gives you a better shell to work in.
5. Is Obsidian installed? Not required — the vault is plain markdown and works without it — but it
   makes the vault pleasant to read. Offer, don't insist.

Report. Then ask permission to continue.

---

## Phase 1 — The interview

Open `interview/INTERVIEW.md` and work through it **in order, one question at a time**.

Do not skip the guardrails section. It is the part that matters most and the part they'll be
tempted to wave through. Read each guardrail out, in your own words, and get an actual answer.

Write nothing until the interview is finished. Then confirm the whole picture back to them in about
eight lines and ask "have I got that right?" before you start building.

---

## Phase 2 — Build the folders

Default layout, all inside their user folder:

```
%USERPROFILE%\EVIE\
├── CLAUDE.md            <- from templates/CLAUDE.md, filled in
├── Vault\               <- their memory
│   ├── VAULT-INDEX.md
│   ├── GUARDRAILS.md
│   ├── Profile.md
│   ├── Active Priorities.md
│   ├── 01 - Daily Notes\
│   │   └── Daily Note Template.md
│   ├── 02 - Subjects\
│   ├── 03 - Projects\
│   ├── 04 - Routines\
│   └── 05 - Reference\
├── droid-kit\           <- this repo (any folder name works)
└── backtalk\            <- the voice engine, added in Phase 4
```

If they already have a notes folder, use it as `Vault` instead of making a new one. Their notes stay
where they are; you add the index, guardrails, and structure around them. **Never move their
existing files.**

Copy the templates in, then fill in every `[FILL IN: ...]` marker from the interview answers. Delete
the AI-facing instruction blocks from the copies once they're filled — those are for the template,
not for the live file.

Create one folder under `02 - Subjects\` per subject or client they named, each with its own index
file.

---

## Phase 3 — Wire up the launchers

1. Run `scripts\Make-Shortcuts.ps1`. It creates four Desktop shortcuts. The two Local ones will
   correctly refuse to start until Phase 6 — that's expected, not a bug. Tell them that, or they'll
   click one, get an error, and lose confidence in the whole thing.
2. **Test Cloud yourself before telling them it works.** Confirm `CLAUDE.md` is where the batch files
   expect it and that `claude` resolves on PATH.
3. Tell them to close this session, double-click **EVIE — Chat (Cloud)** on the Desktop, and say
   hello.

There is no mode setting to configure. Each launcher passes `cloud` or `local` to
`scripts\evie-env.cmd` itself, and everything it sets is scoped to that one window.

If `claude` isn't found after install, the fix is almost always that the terminal was open before
Claude Code was installed. Tell them to close every terminal window and try again.

---

## Phase 4 — Wire up Talk

Ask first: *"Do you want the voice now, or later? It's another ~1 GB of downloads and it needs a
microphone."* Later is a fine answer — Chat is the part that does the work.

If yes:

1. Clone `https://github.com/jaredrhod/backtalk` into `%USERPROFILE%\EVIE\backtalk`.
2. Install `uv` if it's missing (ask first).
3. Follow **backtalk's own Windows instructions** — open that folder and read its `backtalk.md`
   wizard. Do not improvise the Python setup; the repo knows its own dependencies, including
   espeak-ng.
4. Copy `config\backtalk.json.example` to `backtalk\backtalk.json` and fill in:
   - `agent_dir` — the absolute path to `%USERPROFILE%\EVIE` (the folder with `CLAUDE.md`).
     **This is what makes the voice EVIE.** Get it wrong and you get a generic assistant with her
     name on it.
   - `name` — `EVIE`
   - `voice` — `af_heart` unless they picked another in the interview
   - `ptt_key` — whatever they chose
5. Launch it once yourself and confirm audio comes out.
6. Tell them: hold the key, speak, let go. The mic is closed the rest of the time.

**Say this out loud to them, once:** the voice session runs with tool permissions bypassed by
default, because a voice conversation has no good way to show an approval prompt. That means EVIE
acts without asking in voice mode. The guardrails in `CLAUDE.md` and `GUARDRAILS.md` are what hold
the line there, which is why the interview spent time on them. If they'd rather approve every action
and watch the terminal, set `"permission_mode": "default"` in `backtalk.json`.

---

## Phase 5 — First run and handover

1. Create today's daily note from the template.
2. Write a short "Setup" entry in it: what was installed, where things live, what was decided.
3. Write `Active Priorities.md` with whatever they said is coming up.
4. Show them, in the terminal, three things they can try right now. Pick from `USE-CASES.md`, and
   pick ones that will actually work on the first try.
5. Tell them the two habits that make this work:
   - **Open Chat and just talk to her.** She learns from being used.
   - **When something breaks, tell her.** Don't debug it yourself.

Then tell them about the local brain: optional, for working without internet, and a real step down
in capability. Point at `GOING-LOCAL.md`.

**Ask whether to set it up now or later.** If their internet is unreliable, or they said in the
interview that they lose connectivity at school, do it now — see Phase 6. Otherwise let them live
with Cloud for a week first. Someone who has never used the thing has no basis for judging the
tradeoff.

---

## Phase 6 — The local brain (only if they want it now)

Check the disk first: the model is 6.6 GB and the tuning script wants room to work.

1. Install Ollama. Ask first, name the size.
2. `ollama pull ornith-1.5:9b`
3. **Run `scripts\Set-OllamaTuning.ps1`.** Do not set context length by hand and do not skip this.
   It reads the actual VRAM and RAM, picks the largest context window the machine can sustain,
   writes the settings as Windows user environment variables, restarts Ollama, and then times a real
   generation to prove it worked.
4. **Read the benchmark result out to them in plain words.** If it reports under 12 tokens/sec, say
   directly that local mode on this laptop is for short jobs and that real work belongs in Cloud.
   Do not oversell it — a student who expects Cloud quality from a 9B model concludes the whole
   thing is broken.
5. Open **EVIE — Chat (Local)** and run the four tests in `GOING-LOCAL.md`. Write the results into
   their vault as a note. That note ends the guessing about which mode to use for what.

**Why the tuning script exists:** `OLLAMA_CONTEXT_LENGTH` cannot be set from a terminal or a batch
file. Ollama is a background service and reads its configuration when it starts. Setting it anywhere
else appears to work and does nothing — which surfaces weeks later as "EVIE forgets things" and gets
blamed on the model.

---

## What not to do

- Don't install the visualizer or barehands. Not in scope here.
- Don't set permanent Windows environment variables by hand. Everything EVIE needs at runtime is set
  per-window by `scripts\evie-env.cmd`. The Ollama settings are the one exception, and
  `Set-OllamaTuning.ps1` owns those — a stray permanent `ANTHROPIC_BASE_URL` is the single nastiest
  bug in this stack, because it makes Cloud silently talk to a local model.
- Don't put the vault in OneDrive, Documents, or Desktop if you can avoid it. Sync services and
  agents fight over file locks.
- Don't write their guardrail answers as a summary. Write them as rules, in their words.
