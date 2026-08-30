# EVIE — a companion agent that lives on your machine

EVIE is an AI companion you install on your own Windows PC. She remembers you between sessions,
you can type to her or talk to her out loud, and once she's set up she can run without an internet
connection.

This repo is the **installer and the starting configuration**. It is deliberately small: three
capabilities, two shortcuts, one interview.

| Piece | What it is | Where it comes from |
|---|---|---|
| **Memory** | A folder of plain markdown files EVIE reads and writes. No database, no cloud. | Adapted from [ai-memory-vault](https://github.com/jaredrhod/ai-memory-vault) |
| **Chat** | A typed terminal session with EVIE. | Claude Code |
| **Talk** | Hold a key, speak, EVIE answers out loud in a local voice. | [backtalk](https://github.com/jaredrhod/backtalk) |

Not included on purpose: the visualizer (face) and the webcam hands board. They are excellent and
you can add them later, but they add hardware requirements and failure modes that get in the way of
a first install.

---

## Who this is for

- **Students** who want a study partner that works offline, keeps their notes, and does the tedious
  parts of coursework without doing the thinking for them.
- **Small business owners and teams** who want an assistant that knows their business, drafts their
  documents, and never touches customer data it shouldn't.

Everything in here is written so a person who has never opened a terminal can finish the install.
If you are technical, skip to [SETUP.md](SETUP.md) and let your agent run it.

---

## Two phases

**Phase 1 — Cloud brain.** EVIE runs on Claude Code with a Claude subscription. Fastest path to a
working agent and the best experience. Needs internet.

**Phase 2 — Local brain.** EVIE runs on a model installed on your own machine through Ollama.
Slower and less capable, but free per-use, private, and works with no internet at all. See
[GOING-LOCAL.md](GOING-LOCAL.md).

Do Phase 1 first, always. After Phase 2 you have **four Desktop shortcuts** and pick a brain by
picking an icon — same EVIE, same memory, same vault behind all of them.

---

## Install

**Requirements**

- Windows 11 (Windows 10 1809+ also works). Native Windows — no WSL needed.
- A Claude Pro, Max, Team, or Enterprise account (~$20/month). The free plan does not include
  Claude Code.
- About 5 GB free disk for Phase 1, plus ~10 GB more if you do Phase 2.
- A microphone, if you want Talk.

**The short version**, in PowerShell:

```powershell
irm https://claude.ai/install.ps1 | iex
```

Close PowerShell, open a new one, then:

```powershell
mkdir $HOME\EVIE; cd $HOME\EVIE
git clone https://github.com/DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit.git droid-kit
cd droid-kit
claude "read SETUP.md and set me up"
```

From there it is a conversation. EVIE interviews you, builds your memory vault, writes your
guardrails, and leaves two shortcuts on your Desktop.

**The long version, with screenshots-level detail and nothing assumed:**
[INSTALL-GUIDE.md](INSTALL-GUIDE.md).

---

## After setup

Shortcuts land on your Desktop. Two after Phase 1, four once you've done Phase 2:

| Shortcut | Brain | Internet | Use it for |
|---|---|---|---|
| **EVIE — Chat (Cloud)** | Claude | Required | Anything hard, long, or that you'll rely on |
| **EVIE — Talk (Cloud)** | Claude | Required | Quizzing, rehearsal, thinking out loud |
| **EVIE — Chat (Local)** | Your machine | None | Offline hours, notes, filing, routine work |
| **EVIE — Talk (Local)** | Your machine | None | Fully offline voice — nothing leaves the laptop |

Each opens a terminal window. That window *is* EVIE — closing it ends the session. Cloud and Local
windows can be open at the same time and cannot interfere with each other.

**When something breaks, tell EVIE.** Open Chat and describe what went wrong in plain words. She
can read [TROUBLESHOOTING.md](TROUBLESHOOTING.md) and fix most of it herself. This is the part
people discover late: you are not expected to debug this.

---

## Repository contents

```
droid-kit/                (whatever you named the cloned folder)
├── SETUP.md              The install wizard. Your agent reads this and runs the install.
├── INSTALL-GUIDE.md      The human step-by-step. No coding background assumed.
├── GOING-LOCAL.md        Phase 2: switching EVIE to a local model with Ollama.
├── TROUBLESHOOTING.md    Known problems and their fixes, written for EVIE to read.
├── USE-CASES.md          Ranked use cases for students, plus a business section.
├── HARDWARE.md           What each laptop tier can actually run.
├── CREDITS.md            Attribution and the licensing reasoning. Read before forking.
├── LICENSE               Apache 2.0.
├── NOTICE                Required attribution file.
├── interview/
│   └── INTERVIEW.md      The questions EVIE asks during setup, in order.
├── templates/
│   ├── CLAUDE.md         EVIE's identity and her non-negotiables. The most important file.
│   ├── GUARDRAILS.md     The safety rules, in one place, in plain language.
│   ├── VAULT-INDEX.md    The vault's operating manual.
│   ├── PROFILE.md        Who you are — EVIE keeps this current.
│   └── DAILY-NOTE.md     The shape of every daily note.
├── scripts/
│   ├── EVIE-Chat-Cloud.bat    Typed session on Claude.
│   ├── EVIE-Chat-Local.bat    Typed session on your own machine.
│   ├── EVIE-Talk-Cloud.bat    Voice on Claude.
│   ├── EVIE-Talk-Local.bat    Voice, fully offline.
│   ├── evie-env.cmd           Shared environment. Takes cloud or local as an argument.
│   ├── Set-OllamaTuning.ps1   Measures your hardware, sets the largest workable
│   │                          context window permanently, proves it worked.
│   └── Make-Shortcuts.ps1     Puts the four shortcuts on the Desktop.
└── config/
    └── backtalk.json.example  Voice settings. Ships with EVIE's default voice.
```

---

## Credits and license

**Apache 2.0.** Use it, teach with it, fork it, build a business on it. Keep `LICENSE` and `NOTICE`
with it and you've met every obligation.

The design owes a real debt to [Jared Rhodenizer's](https://jaredrhod.com) work — `ai-memory-vault`
showed that an AI's memory can be a folder of markdown files instead of a database, and `backtalk`
is the voice engine this module installs. Neither is included here: the ideas are shared, the code
and text are not, and `backtalk` is downloaded from its own repository at setup so its AGPL terms
stay where they belong.

Local model: [Ornith 1.5 9B](https://ollama.com/library/ornith-1.5) (MIT). Voice:
[Kokoro](https://github.com/hexgrad/kokoro) (Apache 2.0). Hearing:
[faster-whisper](https://github.com/SYSTRAN/faster-whisper) (MIT).

Full reasoning, and the two rules that keep this license valid, in [CREDITS.md](CREDITS.md).
