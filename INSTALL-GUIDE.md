# Installing EVIE — the step-by-step

Written for someone who has never opened a terminal. If a step doesn't look like what you see on
screen, stop and read the note under it before continuing.

**Time:** about 30–45 minutes, plus 30–90 minutes of download time if you add the offline brain.
**You need:** Windows 11 (or 10, version 1809+), a **Claude subscription** (Pro or higher) for this
first install, about 5 GB of free disk (20 GB with the offline brain), and a microphone if you want voice.

---

## What you're installing

- **EVIE**, a companion agent built on **Claude Code**, with a memory made of plain files on your PC.
- **Two brains:**
    - **Paid**: Claude, through your subscription. The smartest option. Needs internet.
    - **Local**: **gpt-oss-20b**, running on your own PC. Works with no internet and **never asks you to
      sign in**, even if your subscription ends. Slower and less capable.
- **Voice** (optional): hold a key, speak, and EVIE answers out loud.

---

## Step 1 — The one line

1. Press the **Windows key**, type `powershell`, and click **Windows PowerShell**.
   The prompt starts with `PS C:\Users\YourName>`. **The `PS` matters.** Without it you opened Command
   Prompt instead. Don't choose "Run as Administrator".
2. Copy this line, paste it (right-click pastes), and press **Enter**:

```powershell
irm https://raw.githubusercontent.com/DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit/main/install.ps1 | iex
```

It works through five steps on screen, skipping anything you already have:

| Step | What happens |
|---|---|
| 1/5 Claude Code | Installs Anthropic's official agent |
| 2/5 Git | Installs Git for Windows (via winget) |
| 3/5 uv | Installs the tool the voice and memory checker run on |
| 4/5 The kit | Downloads this kit to `C:\Users\YourName\EVIE\droid-kit` |
| 5/5 Setup | Starts EVIE's setup conversation |

> **If it says winget is missing:** open the Microsoft Store, update **App Installer**, and run the
> line again. **If anything else fails:** read the red message. The installer is safe to run again,
> and it never deletes anything.

---

## Step 2 — Sign in, once

When setup starts, **your browser opens and asks you to log in to Claude.** Use the account that has
your subscription, then return to PowerShell when the browser says you can.

This sign-in belongs to the **Paid** shortcuts only. The Local shortcuts use a separate, sealed
profile that has never been signed in, so they will **never** show this screen, even a year from now
with no subscription.

---

## Step 3 — The interview

EVIE asks about twenty-five questions, one at a time: who you are, what you're studying or what your
business does, what's on your plate, how you want her to behave, and whether you want voice and the
offline brain.

**Answer specifically.** "I have a lot of subjects" is a wasted answer. "Calculus, Gen Bio, Research 2
and Filipino, and Research is the one killing me" gives her something to work with. Everything you
say becomes her memory.

**Actually read the guardrails part.** Never deleting without asking, never sending anything
without showing you first, never writing your graded work. You're giving a program the ability to
write files on your computer, and those rules are the fence. At the end she reads the whole picture
back. Check it, then say yes.

---

## Step 4 — She builds everything

EVIE now does the work, narrating as she goes. Read any permission request before saying yes.

1. **Her home and memory.** She creates `EVIE\CLAUDE.md` (who she is) and `EVIE\Vault` (her memory),
   set up as a small wiki:

   | In the vault | What it is |
   |---|---|
   | `index.md` | A catalog: every page, one line each |
   | `log.md` | A timeline of every change. She writes an entry before and after every task |
   | `raw\` | Drop sources here (handouts, articles, briefs). She reads them, never edits them |
   | `outputs\` | Answers worth keeping |
   | `VAULT-INDEX.md` | The rules of the memory |
   | `GUARDRAILS.md` | The safety rules, in your words |

   It never overwrites a file that already exists.
2. **Safety hooks.** A guard that **pauses any delete or move inside EVIE's folder** until you approve
   it, plus an automatic "save what matters" step whenever a long conversation gets compressed.
3. **Four Desktop shortcuts.** The two Local ones say "not installed yet" until Step 6. That's
   expected.
4. **Voice**, if you said yes: a ~1 GB download.

---

## Step 5 — First Paid session

Double-click **EVIE - Chat (Paid)**. A window opens and she says hello. Type to her. **That window is
EVIE.** Closing it ends the conversation, but everything she learned is saved in the vault.

Try these three, in order:

1. `What do you know about me?` She reads her memory back, which proves the vault works.
2. `Make me a study plan for the next two weeks based on my deadlines.`
3. `Quiz me on [something you have notes for]. Five questions, one at a time.`

---

## Step 6 — The offline brain (gpt-oss), if you want it

If you said yes in the interview, EVIE starts this herself. Otherwise, say **"install my local brain"**
in Chat (Paid) any time. A separate window opens and runs the installer, which:

1. measures your PC;
2. downloads **llama.cpp** (the engine) and **gpt-oss-20b** (the model, 12.1 GB). It resumes if your
   connection drops: just run it again;
3. **loads the model for real** to find the best fit for your graphics card and memory;
4. times it, and **proves tool calling works** (that she can actually use tools, not just chat);
5. **proves the Local shortcut works with no sign-in.**

Leave that window open until it says **"Local brain installed and proven."** EVIE reads the result to
you, including the speed in words per second.

Then double-click **EVIE - Chat (Local)**. A small minimised window called *EVIE local brain* opens
first. That's the model, so leave it open while you work. The first start takes a minute or two.

---

## Step 7 — Your shortcuts

| Shortcut | Brain | Needs internet | Sign-in |
|---|---|---|---|
| **EVIE - Chat (Paid)** | Claude | Yes | Your subscription |
| **EVIE - Talk (Paid)** | Claude | Yes | Your subscription |
| **EVIE - Chat (Local)** | gpt-oss-20b | No | **Never** |
| **EVIE - Talk (Local)** | gpt-oss-20b | No | **Never** |

**Voice:** hold your push-to-talk key, speak, and let go. Press it again while she's talking to
interrupt. Say "goodbye EVIE" or close the window to hang up. **Use one voice window at a time.**

**If your subscription ends,** the Paid shortcuts will ask you to sign in again. The Local ones keep
working exactly as before, with nothing to change.

---

## The habits that make this worth it

- **Open Chat once a day and talk to her.** The memory gets more useful every time you use it.
- **Hand her sources:** drop a file in `Vault\raw` and say "ingest it".
- **Ask her to "check the vault" now and then,** to clean up duplicates and stale notes.
- **When something breaks, tell her.** She reads `TROUBLESHOOTING.md` and fixes most things herself.
  You're not expected to debug this.
- **If a window ever hangs, close it and reopen the shortcut.** Never end EVIE's hidden processes
  from Task Manager.

---

## Common first-day problems

| What you see | What it means | Fix |
|---|---|---|
| `claude is not recognized` | That window was opened before the install | Close every terminal, open a new one |
| Browser login loops | Wrong account, or a free account | Log in with the subscription account |
| A window flashes and closes | The EVIE folder was moved, or setup didn't finish | Move it back, or tell EVIE in Chat (Paid) |
| Local says "not installed yet" | The offline brain isn't set up | Say "install my local brain" in Chat (Paid) |
| Local is very slow | Your hardware, or a browser holding graphics memory | Close the browser; see `HARDWARE.md` |
| A delete pauses for approval | The delete-protection guard | Approve only if you meant it |
| Voice won't start, "another Talk window is open" | Two voice sessions | Close the other one |
| Talk (Paid) says "OAuth session expired" | The subscription sign-in lapsed | Chat (Paid) → type `/login` |
| She reads out "asterisk" in voice | She formatted a spoken reply | Tell her "plain sentences, you're on voice" |
| Frozen after "opening Excel" | An app launched in the foreground | Close the app or the window, then reopen |

Everything else is in **TROUBLESHOOTING.md**.
