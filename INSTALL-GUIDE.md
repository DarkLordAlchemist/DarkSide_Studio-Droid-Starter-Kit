# Installing EVIE — the step-by-step

Written for someone who has never opened a terminal. If a step doesn't look like what you see on
screen, stop and read the note under it before continuing.

**Time:** about 40 minutes, most of it downloading and answering questions.
**You need:** Windows 11, a Claude subscription, and about 5 GB of free space.

---

## Before you start

**Get a Claude subscription.** Go to [claude.ai](https://claude.ai) and subscribe to Pro (about
$20/month). The free plan does not include Claude Code, which is the piece that makes EVIE able to
touch files on your computer. There is no way around this in Phase 1.

**Know your username.** Press `Win + R`, type `cmd`, press Enter, and look at the prompt. It says
something like `C:\Users\Ross>`. The word after `Users\` is your username. Write it down; a few
steps refer to it.

---

## Step 1 — Open PowerShell

Press the **Windows key**, type `powershell`, and click **Windows PowerShell**.

A blue or black window opens with a prompt that starts with `PS C:\Users\YourName>`.

> **The `PS` matters.** If your prompt starts with `C:\` and no `PS`, you opened Command Prompt
> instead. Close it and try again — the commands below only work in PowerShell.

You do not need to "Run as Administrator." If something later tells you that you do, stop and ask.

---

## Step 2 — Install Claude Code

Copy this line, paste it into PowerShell (right-click pastes), and press Enter:

```powershell
irm https://claude.ai/install.ps1 | iex
```

Wait. It downloads and installs itself. When it finishes you'll see a success message.

**Now close the PowerShell window completely and open a new one.** This is not optional and it is the
single most common reason the next step fails. Windows only notices the new program in a terminal
that was opened after the install.

In the new window, check it worked:

```powershell
claude --version
```

You should see a version number like `2.1.211 (Claude Code)`.

<details>
<summary><b>It said "claude is not recognized"</b></summary>

You almost certainly reused the old window. Close every terminal window on your machine, open a
fresh PowerShell, and try again.

If it still fails, run `claude doctor` — it prints a diagnosis. If that command isn't found either,
the install didn't complete; run the install line again and read the output carefully for an error.
</details>

---

## Step 3 — Install Git (recommended)

Download and install [Git for Windows](https://git-scm.com/downloads/win). Click through the
installer with all the defaults — none of the options matter for this.

This is technically optional. It gives EVIE a better toolset for working with files on Windows, and
it's what lets Step 4's `git clone` command work. If you skip it, ask EVIE to install it later.

**Close and reopen PowerShell again** after installing.

---

## Step 4 — Download EVIE and start the install

Paste these three lines, one at a time, pressing Enter after each:

```powershell
mkdir $HOME\EVIE
cd $HOME\EVIE
git clone https://github.com/DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit.git droid-kit
```

> The `droid-kit` on the end is the folder name it downloads into. Without it you get a folder named
> after the whole repository, which works fine but makes every path long. If your teacher or IT gave
> you a different link, use theirs.

Then:

```powershell
cd droid-kit
claude "read SETUP.md and set me up"
```

**The first time you run `claude`, it opens your web browser and asks you to log in.** Log in with
the account that has your subscription. The browser will say you can close the tab; go back to
PowerShell.

---

## Step 5 — The interview

EVIE now talks to you. She'll ask about twenty questions: who you are, what you're studying or what
your business does, what's on your plate, and how you want her to behave.

**Answer honestly and specifically.** "I have a lot of subjects" is a wasted answer. "Calculus,
Gen Bio, Research 2, and Filipino, and Research is the one killing me" gives her something to work
with. Everything you say here becomes her memory.

**The guardrails section is the part to actually read.** She'll walk you through what she will and
won't do — never deleting without asking, never sending anything without showing you first, never
writing your graded work. Say yes, or change it, but don't skim it. You're about to give a program
the ability to write files on your computer, and those rules are the fence.

When she's done she'll read the whole picture back to you. Check it. Then say yes.

---

## Step 6 — Let her build

She creates your folders, writes your files, and sets up two shortcuts. Watch the terminal — she
narrates what she's doing. If she asks permission for something, read the request before saying yes.

When she finishes she'll tell you to close the session and use the Desktop shortcut instead.

---

## Step 7 — Your first real session

On your Desktop you now have:

- **EVIE — Chat (Cloud)** — double-click it. A terminal window opens and she says hello. Type to her.
- **EVIE — Talk (Cloud)** — voice, if you set it up. Hold the key, speak, let go.

If you also set up the local brain, two more appear: **EVIE — Chat (Local)** and
**EVIE — Talk (Local)**. Those run entirely on your laptop with no internet. They're slower and
she's less capable, but they work on a bus, in a brownout, or on school wifi that has given up.

**Pick a brain by picking an icon.** There's nothing to configure and nothing to switch. You can have
a Cloud window and a Local window open at the same time.

**That terminal window is EVIE.** Closing it ends the conversation. She'll still remember
everything — it's all written to your vault — but the current thread is over.

Try these three, in order:

1. `What do you know about me?` — she reads her memory back. This proves the vault works.
2. `Make me a study plan for the next two weeks based on my deadlines.`
3. `Quiz me on [something you have notes for]. Five questions, one at a time, don't give me the answers.`

---

## Step 8 — The habit that makes this worth it

Open Chat once a day. Tell her what happened. Ask her for the thing you were about to do manually.

The vault gets more useful every time you use it, and useless if you don't. An empty memory system is
just a folder.

**And when something breaks — tell her.** Open Chat, describe what went wrong in plain words, and let
her read `TROUBLESHOOTING.md` and fix it. That is a real workflow, not a joke. You are not expected
to debug this yourself.

---

## Common first-day problems

| What you see | What it means | Fix |
|---|---|---|
| `claude is not recognized` | Terminal opened before install | Close every terminal, open a new one |
| Browser login loops | Wrong account, or a free account | Log in with the account that has the subscription |
| An EVIE window flashes and closes | Batch file can't find `CLAUDE.md` | The `EVIE` folder was moved or renamed. Move it back, or rerun setup |
| Local shortcut says Ollama isn't installed | You haven't done the local setup | Use a Cloud shortcut, or see GOING-LOCAL.md |
| Local shortcut warns about context length | Tuning script hasn't run | Right-click `scripts\Set-OllamaTuning.ps1` → Run with PowerShell |
| She says she can't find your vault | Path in `CLAUDE.md` doesn't match reality | Open Chat and say "your vault path is wrong, fix it" |
| Voice window says `uv` not found | Voice engine setup didn't finish | Open Chat and say "finish my voice setup" |
| She's very slow | Usually a big vault read or a long task | Ask her what she's doing — she'll tell you |

More in [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
