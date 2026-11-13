# Going local — EVIE on gpt-oss-20b, with no internet

The point of the Local lane is **availability, not capability**. EVIE on gpt-oss-20b is slower and
less capable than EVIE on Claude. What you gain: no internet, no usage limits, no per-use cost,
nothing leaving the machine, and **no subscription or sign-in, ever**. It keeps working the day a
subscription lapses.

---

## How it fits together

```
EVIE - Chat (Local).bat
   │  evie-env.cmd local  (this window only)
   │    CLAUDE_CONFIG_DIR = EVIE\local\claude-profile   <- a profile that has never been signed in
   │    ANTHROPIC_BASE_URL = http://127.0.0.1:8085      <- the local brain
   │    ANTHROPIC_AUTH_TOKEN = local-no-login           <- so Claude Code never asks you to log in
   ▼
Claude Code  (tools, files, hooks, your CLAUDE.md and vault: identical to Paid)
   │  Anthropic Messages API  (/v1/messages)
   ▼
llama.cpp llama-server (build b11871)  →  gpt-oss-20b (MXFP4, 12.1 GB)
```

**Why llama.cpp and gpt-oss.** llama.cpp's server speaks Claude Code's own API directly, so there's
no translator in between. It runs gpt-oss's own chat template (`--jinja`), which is what makes
**tool calling** work. And `--n-cpu-moe` lets a 20B "mixture of experts" model run on an 8 GB card by
keeping some of its experts in RAM. gpt-oss-20b is Apache-2.0 and built for tool use.

Same vault, same guardrails, same EVIE. Only the brain changes.

---

## Install it (one script)

From EVIE - Chat (Paid), say **"install my local brain"**, or run it yourself in its own window:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\EVIE\droid-kit\scripts\Install-LocalBrain.ps1"
```

About 12.5 GB of downloads (it resumes if the connection drops), then roughly five minutes of checks.
It runs these steps and **proves** each one:

| Step | What it proves |
|---|---|
| 1. Measures the PC | GPU, VRAM, driver, RAM, disk: decides everything below |
| 2. llama.cpp b11871 | The exact build this kit was tested on, in the right flavour: CUDA 13 (NVIDIA driver 580+), CUDA 12 (older NVIDIA), Vulkan (AMD/Intel), or CPU |
| 3. gpt-oss-20b | Downloaded, then checked byte for byte (12,109,566,624 bytes) |
| 4. Fit | **Loads the model for real** at the planned context and GPU/RAM split. If it doesn't fit, or leaves under 500 MB of VRAM, it backs off and tries again |
| 5. Speed | Times a real answer, in tokens/sec |
| 6. Tool calling | Asks gpt-oss a question that needs a tool, and checks it calls the tool correctly |
| 7. No sign-in | Seeds the sealed Local profile, then has **Claude Code** run a real Bash tool through gpt-oss with no login |
| 8. Saves | `EVIE\local\brain.cmd`, which both Local shortcuts read |

The result is written to `EVIE\local\install-status.json`, which EVIE reads.

**Starting points it uses** (only the 8 GB row was measured; the load test corrects the others on
your machine):

| VRAM | Context | Experts kept in RAM (`--n-cpu-moe`) |
|---|---|---|
| 20 GB+ | 131,072 | 0 |
| 16 GB | 131,072 | 3 |
| 12 GB | 131,072 | 10 |
| 10 GB | 131,072 | 14 |
| **8 GB (measured: RTX 5070 Laptop, ~22 tok/s, 1.2 GB VRAM spare)** | **131,072** | **18** |
| 6 GB | 65,536 | 22 |
| No GPU | 32,768 | all (CPU only, slow) |

The context memory lives on the graphics card, so system RAM doesn't limit context. RAM holds the
experts that don't fit on the card, which is why 16 GB is the floor.

---

## Use it

Double-click **EVIE - Chat (Local)**. It starts the brain in a minimised window called
*EVIE local brain* (leave that open; it **is** the model), then opens EVIE. The first load takes a
minute or two. The GPU holds one model at a time, so the launcher stops any other llama-server first.

**Paid and Local can be open at the same time.** Each launcher sets its own environment inside its
own window. The vault is shared, so work done in one is there in the other.

**What the Local lane can use:** Read, Write, Edit, Bash, Glob, Grep, WebFetch and TodoWrite.
**No WebSearch** (it's an Anthropic server feature) and **no MCP servers or connectors**
(gpt-oss's template crashes on some of their schemas). Both are deliberate, not missing.

---

## Test it honestly (once, then stop guessing)

1. **Memory:** `What do you know about me?` She should read the vault and answer.
2. **File write:** `Create a note called Local Test in 05 - Reference with today's date in it.`
3. **Multi-step:** `Read my three most recent daily notes and list every open task in one place.`
4. **Long haul:** something that takes six or seven tool calls.

Most setups pass 1 and 2, wobble on 3, and struggle on 4. Write your results into the vault: that
note tells you which tasks belong in Paid.

---

## What gets worse, honestly

- **Long tool chains drift.** The failure looks like looping or losing the goal, not an error.
- **Slower as a session grows.** Every turn re-reads the conversation. Start fresh sessions often.
  Auto-compaction is set to trigger at about 80% of the real context.
- **Fixed knowledge, no web search.** She'll answer recent-events questions anyway, so don't trust those.
- **Maths and precise reasoning degrade.** Have her show her work, and check it.

**What holds up:** reading and writing vault notes, summarising, reformatting, quiz questions and
flashcards, drafting from an outline, sorting and renaming files, explaining a concept five ways.

## The realistic pattern

Use both. **Paid** for anything hard, long, research-shaped, or that you'll rely on. **Local** for
offline hours and routine work. The vault is shared, which is the whole reason the memory lives in
files instead of inside a model.

---

## For a classroom or an office

One machine with a big GPU can serve the room. On the host, start llama-server with
`--host 0.0.0.0` (edit the `--host` in `scripts\start-local-brain.cmd`) and raise `-np` to the number
of simultaneous users. **Each parallel slot needs its own context memory,** so lower `-c` to match.
On each client, set `EVIE_LLM_PORT` and change `127.0.0.1` in `scripts\evie-env.cmd` to the host's
address, and skip `Install-LocalBrain.ps1` on the clients except step 7 (the sealed profile). Vaults
stay on each person's own machine; only the model is shared.
