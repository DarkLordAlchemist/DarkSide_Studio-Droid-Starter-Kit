# Pushing this to GitHub — one-time checklist

Repo: `DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit` (currently empty, public)

Delete this file once you've done it. It's scaffolding, not documentation.

---

## 1. Put your real name in two files

`LICENSE` and `NOTICE` both say `Ross`. Replace with whatever you want on the copyright line —
your full name, or `DarkSide Studio`, or both. This is the one thing that's genuinely awkward to
change after other people have forked it.

```powershell
# From the kit folder, in PowerShell:
(Get-Content LICENSE) -replace '2026 Ross', '2026 Your Name' | Set-Content LICENSE
(Get-Content NOTICE)  -replace 'Copyright 2026 Ross', 'Copyright 2026 Your Name' | Set-Content NOTICE
```

## 2. Push

```powershell
cd <the kit folder>
git init
git add .
git commit -m "Initial commit: EVIE companion module, Apache 2.0"
git branch -M main
git remote add origin https://github.com/DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit.git
git push -u origin main
```

If it asks for credentials, use a personal access token as the password, not your GitHub password.
GitHub stopped accepting passwords for git operations.

## 3. Check the line endings survived

Look at `scripts/EVIE-Chat-Cloud.bat` on GitHub. If it renders as one long line, `.gitattributes`
didn't apply — fix it before anyone clones:

```powershell
git rm --cached -r .
git reset --hard
git add .
git commit -m "Normalise line endings"
git push
```

**Why this matters:** a `.bat` file with Unix line endings can fail on `GOTO` and on multi-line
blocks, silently and confusingly. `.gitattributes` forces CRLF for `.bat`, `.cmd`, and `.ps1`.

## 4. Set the repo up on GitHub

- **Description:** *An AI companion agent that lives on your own hardware. Memory, chat, and voice —
  cloud or fully offline. Built for students and small businesses.*
- **Topics:** `ai-agent` `claude-code` `ollama` `local-llm` `education` `offline-ai` `windows`
  `ai-memory` `edtech` `philippines`
- **License:** GitHub reads `LICENSE` automatically and should show an Apache-2.0 badge within a
  minute. If it doesn't, the file was modified in a way the detector didn't recognise — put the
  canonical text back.
- Leave Issues on. When students hit problems, that's where you'll find out.

## 5. Verify the whole thing on a clean machine

The install works or it doesn't, and you find out by doing it, not by reading it. On a laptop that
has never had any of this:

```powershell
irm https://claude.ai/install.ps1 | iex
# close PowerShell, open a new one
mkdir $HOME\EVIE; cd $HOME\EVIE
git clone https://github.com/DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit.git droid-kit
cd droid-kit
claude "read SETUP.md and set me up"
```

Do this before the PC Express presentation, not during it. Watch specifically for:

- Does the wizard actually stop and wait after each interview question, or does it run ahead?
- Do all four Desktop shortcuts get created?
- Do the Local ones fail *gracefully* (a clear message, not a flash-and-close) before Ollama exists?
- Does `Set-OllamaTuning.ps1` detect the right VRAM on that machine?

## 6. Before the first class

- Add a `docs/` folder or a wiki page with your own screenshots. Written steps carry a student to
  about step 4; screenshots carry them the rest of the way.
- Tag a release (`v1.0`) once you've verified it. Students clone `main` and `main` moves; a tag is
  the version you actually tested and can point a room at.
