# Going local — running EVIE with no internet

This is Phase 2. Do it only after Phase 1 works and you've used EVIE for at least a few days.

The point of local mode is **availability, not capability**. EVIE on a local model is slower and
noticeably less capable than EVIE on Claude. What she gains is: no internet needed, no usage limits,
no per-use cost, and nothing leaving the machine. For a student on unreliable campus wifi, or a
business with data that can't go out, that trade is often worth it.

---

## What makes this simple now

Since v0.14.0, **Ollama speaks the Anthropic Messages API natively** at `/v1/messages`. That means
Claude Code can point straight at Ollama with two environment variables. No LiteLLM, no translation
proxy, no router. If you've read older guides that insist on a proxy layer, they predate this.

```
EVIE — Chat (Local).bat
     │  sets ANTHROPIC_BASE_URL=http://localhost:11434, in this window only
     ▼
Claude Code (the harness: tools, files, permissions, your CLAUDE.md)
     │  Anthropic Messages API
     ▼
Ollama on your machine  →  ornith-1.5:9b
```

Everything else stays identical. Same vault, same guardrails, same shortcuts, same EVIE. Only the
brain changes.

---

## Step 1 — Install Ollama

Download from [ollama.com](https://ollama.com/download) and run the installer. It installs itself as
a background service and starts automatically. Nothing to configure yet.

Check it:

```powershell
ollama --version
```

---

## Step 2 — Pull the model

```powershell
ollama pull ornith-1.5:9b
```

6.6 GB. On a slow connection this is a "start it and go do something else" step.

**Why this model.** Ornith 1.5 9B is a dense 9B model built for agentic and tool-calling work — which
is exactly what EVIE does all day. It's the smallest of the Ornith 1.5 family and the only one that
fits an 8 GB card. The Ollama tag ships a Q4_K_M build with a 256K context window and vision.

**Other models that work.** Anything in Ollama's library with a `tools` tag. If you have more VRAM,
`ornith-1.5:35b` (23 GB) is a real step up. If you have less, or no GPU at all, a 4B-class model will
run but will struggle with multi-step tool use — expect it to lose the thread.

Test it on its own before involving EVIE:

```powershell
ollama run ornith-1.5:9b "Say hello in one sentence."
```

If that's slow or fails, fix it here. Don't move on and blame EVIE for it.

---

## Step 3 — Tune it to your hardware (one script, don't skip it)

Right-click `scripts\Set-OllamaTuning.ps1` and choose **Run with PowerShell**. About a minute.

It reads your actual VRAM and RAM, picks the largest context window your machine can sustain, writes
every relevant setting permanently, restarts Ollama, and then times a real answer to prove the
settings took. It prints what it chose and why.

**Why a script instead of instructions.** `OLLAMA_CONTEXT_LENGTH` cannot be set from a terminal or a
batch file. Ollama runs as a background Windows service and reads its configuration when *it* starts.
Set it anywhere else and it looks like it worked while doing nothing — which shows up weeks later as
EVIE forgetting what she was doing, and gets blamed on the model.

**What it sets:**

| Setting | Why |
|---|---|
| `OLLAMA_CONTEXT_LENGTH` | The big one. How much EVIE can hold at once. Sized to your VRAM. |
| `OLLAMA_KV_CACHE_TYPE=q8_0` | Halves the memory the context cache uses, for a quality difference nobody notices. |
| `OLLAMA_NUM_PARALLEL=1` | **Matters more than it looks.** Each concurrent slot gets its own context cache, so leaving this at the default can multiply your VRAM use and quietly undo the context setting. |
| `OLLAMA_MAX_LOADED_MODELS=1` | One student, one model. Don't hold two in VRAM. |
| `OLLAMA_KEEP_ALIVE=15m` | Stay warm between questions, release VRAM eventually. |

**What it picks**, before the RAM check trims it:

| VRAM | Context |
|---|---|
| 24 GB+ | 262,144 (the model's maximum) |
| 16 GB | 131,072 |
| 12 GB | 65,536 |
| 10 GB | 49,152 |
| 8 GB | 32,768 |
| 6 GB | 16,384 |
| under 6 GB, or no GPU | 8,192 |

Then it caps: under 16 GB of system RAM it won't go past 16,384, and under 32 GB not past 65,536.
Anything that doesn't fit in VRAM spills into RAM, so RAM is a real second ceiling.

**Override it** if you know better:

```powershell
.\Set-OllamaTuning.ps1 -Context 65536
```

**8 GB VRAM, honestly.** `ornith-1.5:9b` is 5.6 GB of weights plus a 0.9 GB vision projector. On an
8 GB card, that plus a 32K context does not all fit, so some layers run from system RAM and
generation slows. It works. The script will tell you exactly how fast, in tokens per second, instead
of leaving you to guess. Under 12 tokens/sec, treat local mode as a place for short jobs.

---

## Step 4 — Use the Local shortcuts

Nothing to configure. Run `scripts\Make-Shortcuts.ps1` if you haven't since installing, and the two
Local icons appear alongside the two Cloud ones.

Double-click **EVIE — Chat (Local)**. The header should read:

```
  ==========================================
    EVIE - Chat        [ LOCAL ]
  ==========================================
    Brain:    ornith-1.5:9b (local, via Ollama)
    Context:  32768 tokens
```

If it says the context isn't set, the tuning script hasn't run. Run it.

**Cloud and Local can be open at the same time.** Each launcher sets its own environment inside its
own window and nothing leaks between them, so you can leave a Cloud session open for the hard thing
and use Local for everything else. The vault is shared, so both see the same memory — work you do in
one is available in the other.

That isolation is deliberate. A permanent `ANTHROPIC_BASE_URL` pointing at Ollama would make your
Cloud sessions silently talk to the local model, and the only symptom would be EVIE seeming to get
worse for no reason. Nothing in this repo ever sets that permanently.

---

## Step 5 — Test it honestly

Run these four and note which ones survive. Do it once, write the results in your vault, and stop
guessing about it afterward.

1. **Memory:** `What do you know about me?` — she should read the vault and answer.
2. **File write:** `Create a note called Local Test in 05 - Reference and put today's date in it.`
3. **Multi-step:** `Read my three most recent daily notes and list every open task in one place.`
4. **Long haul:** something that takes six or seven tool calls.

Most local setups pass 1 and 2, wobble on 3, and fail on 4. That's the honest shape of it, and it
tells you exactly which tasks to keep in cloud mode.

---

## What actually gets worse

Be realistic about this so you don't waste an afternoon thinking something's broken.

- **Long tool chains drift.** The failure mode is looping or forgetting the goal, not erroring out.
  This is the big one.
- **No prompt caching.** Every turn reprocesses the whole conversation from scratch, so replies get
  slower as a session gets longer. Start fresh sessions more often than you would on cloud.
- **Knowledge of recent events is fixed** at whenever the model was trained, with no web access.
- **Maths and precise reasoning degrade.** Have her show her work; check it.
- **`tool_choice` is ignored** by the compatibility layer, so occasionally she'll pick the wrong tool
  and get stuck. Ctrl+C and rephrase.

**What holds up fine:** reading and writing vault notes, summarising, reformatting, generating quiz
questions and flashcards, drafting from an outline, renaming and sorting files, explaining a concept,
being asked the same question five ways.

---

## The realistic pattern

Don't pick one mode. Use both.

- **Cloud** for anything hard, long, research-shaped, or that you'll rely on: exam prep, a real draft,
  planning a project, anything with more than about five steps.
- **Local** for the offline hours, and for anything routine: capturing notes, quizzing yourself,
  reformatting, filing, "what did I say I'd do today."

The vault is shared, so work you do in one mode is available in the other. That's the whole reason
the memory lives in files instead of inside the model.

---

## For a classroom or an office

If you're deploying this to a group, don't put a model on every machine — most student laptops can't
run one well, and 30 people downloading 6.6 GB will end your network.

Run **one Ollama host on the LAN** and point everyone at it:

- On the host, set `OLLAMA_HOST` to `0.0.0.0:11434` in its user environment variables and restart
  Ollama, so it accepts connections from the network rather than only from itself.
- On each client, edit `scripts\evie-env.cmd` and change `ANTHROPIC_BASE_URL` in the `:local_brain`
  section to `http://<host-ip>:11434`. One line, one file, and the Local shortcuts pick it up.
- On the host, run `Set-OllamaTuning.ps1` but then raise `OLLAMA_NUM_PARALLEL` to match how many
  students will be connected at once. **Each parallel slot gets its own context cache**, so a 24 GB
  card running a 9B at 32K context serves a handful of simultaneous users, not forty. Budget
  accordingly, or plan on students working in pairs.
- Skip the tuning script on the client machines. They aren't running a model.
- The host needs a real GPU. This is the one piece of hardware worth spending on.

Everything else — vaults, guardrails, shortcuts — stays on each student's own machine. Their notes
are theirs and never touch the server.
