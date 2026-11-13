# EVIE — a companion agent that lives on your machine

EVIE is an AI companion you install on your own Windows PC. She remembers you between sessions,
you can type to her or talk to her out loud, and she can run fully offline on a model on your own
machine, with no subscription and no sign-in.

| Piece | What it is |
|---|---|
| **The agent** | [Claude Code](https://code.claude.com): the harness that gives EVIE hands (files, tools, commands). |
| **Memory** | A folder of plain markdown files run as an **LLM wiki**, after Andrej Karpathy's pattern: sources in `raw/`, a catalog in `index.md`, a timeline in `log.md`, and regular health checks. No database, no cloud. |
| **Paid brain** | Claude, through your subscription. The best experience. Needs internet. |
| **Local brain** | **gpt-oss-20b** on **llama.cpp**, on your own PC. Offline, free per use, **never asks you to sign in**, tool calling included. |
| **Talk** | Hold a key, speak, EVIE answers out loud ([backtalk](https://github.com/jaredrhod/backtalk), downloaded at setup). |

---

## Install — one line

Open **Windows PowerShell** (not as Administrator) and paste:

```powershell
irm https://raw.githubusercontent.com/DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit/main/install.ps1 | iex
```

That installs Claude Code, Git and uv if they're missing, downloads this kit to
`%USERPROFILE%\EVIE\droid-kit`, and starts the setup conversation. EVIE interviews you, builds her
memory, sets up voice and, if you want it, the offline gpt-oss brain, then leaves four shortcuts on
your Desktop.

**You need a Claude subscription (Pro or higher) for this first install,** because the setup interview
runs on it. After that, the Local shortcuts work with no subscription at all.

Full walkthrough, nothing assumed: **[INSTALL-GUIDE.md](INSTALL-GUIDE.md)** (also in the PDF install book).

---

## After setup: four shortcuts

| Shortcut | Brain | Internet | Sign-in | Use it for |
|---|---|---|---|---|
| **EVIE - Chat (Paid)** | Claude | Required | Subscription | Anything hard, long, or that you'll rely on |
| **EVIE - Talk (Paid)** | Claude | Required | Subscription | Quizzing, rehearsal, thinking out loud |
| **EVIE - Chat (Local)** | gpt-oss-20b | None | **Never** | Offline hours, notes, filing, routine work |
| **EVIE - Talk (Local)** | gpt-oss-20b | None | **Never** | Fully offline voice: nothing leaves the PC |

Pick a brain by picking an icon. Paid and Local windows can be open at the same time and can't
interfere with each other. The memory is shared.

**When something breaks, tell EVIE.** Open Chat and describe it. She reads
[TROUBLESHOOTING.md](TROUBLESHOOTING.md), which covers every failure found while building this, and
fixes most things herself.

---

## Repository contents

```
droid-kit/
├── install.ps1            The one-line installer.
├── SETUP.md               The install wizard EVIE follows.
├── INSTALL-GUIDE.md       The human step-by-step (source of the PDF install book).
├── GOING-LOCAL.md         The offline gpt-oss brain: how it works, what to expect.
├── TROUBLESHOOTING.md     Every known problem and its fix, written for EVIE to read.
├── USE-CASES.md           Ranked use cases for students, plus a business section.
├── HARDWARE.md            What each laptop tier can run.
├── CREDITS.md / LICENSE / NOTICE
├── docs/                  EVIE-Install-Book.pdf (the install book), WHATS-BAKED-IN.md
│                          (every past problem → its fix), build-install-book.py
├── interview/INTERVIEW.md The questions EVIE asks during setup.
├── templates/             CLAUDE.md, GUARDRAILS, VAULT-INDEX (the wiki rules), PROFILE,
│                          DAILY-NOTE, vault/ (index, log, raw, outputs), claude/ (the wiki skill)
├── scripts/
│   ├── EVIE-Chat-Paid.bat / EVIE-Talk-Paid.bat
│   ├── EVIE-Chat-Local.bat / EVIE-Talk-Local.bat
│   ├── evie-env.cmd            Per-window environment: paid or local (sealed profile).
│   ├── start-local-brain.cmd   Starts gpt-oss on llama.cpp if it isn't running.
│   ├── Install-LocalBrain.ps1  Downloads, fits, and PROVES the local brain.
│   ├── Setup-EvieHome.ps1      Builds EVIE's folder, vault, hooks, shortcuts. Never overwrites.
│   ├── Set-BacktalkModel.ps1   Points the voice at the right brain on every start.
│   ├── talk-preflight.cmd      Voice checks (one voice window at a time).
│   ├── Make-Shortcuts.ps1      The four Desktop shortcuts.
│   ├── wiki-lint.py            Read-only vault health check.
│   └── hooks/                  Delete protection + compaction sweep (PowerShell).
└── config/backtalk.json.example
```

---

## Credits and license

**Apache 2.0.** Keep `LICENSE` and `NOTICE` with it and you've met every obligation. Ideas from
[Jared Rhodenizer](https://jaredrhod.com) (file-based memory, backtalk) and
[Andrej Karpathy](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (the LLM wiki
pattern). No one else's code or text is included. Local model: gpt-oss-20b (Apache-2.0) on llama.cpp
(MIT). Full reasoning in [CREDITS.md](CREDITS.md).
