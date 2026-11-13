# What each machine can actually run

Written for the conversation where someone asks "which laptop do I need?" The honest answer has two
halves, and the first half is free.

---

## Nobody needs a GPU for the Paid lane

EVIE on Paid runs on a Claude subscription. The model lives on Anthropic's servers. Chat and Talk both
work on a machine with integrated graphics and 8 GB of RAM: Windows 10 1809 or newer, plus internet.

**Everything in Tier 1 of `USE-CASES.md` works fully with no graphics card at all.** Say this first.
A student who can't afford a gaming laptop should not walk away thinking this isn't for them.

The GPU buys one thing: **the Local lane**, which is gpt-oss-20b working with no internet and no
subscription.

---

## The tiers (Local lane = gpt-oss-20b on llama.cpp)

gpt-oss-20b is 12.1 GB on disk. It's a "mixture of experts" model, so part of it can sit in RAM while
the rest runs on the GPU. That's why an 8 GB card works at all, and why **system RAM matters as much
as VRAM** here. `Install-LocalBrain.ps1` measures your machine and proves the fit by loading the model.

### Tier 0 — Paid only
**Any Windows laptop · 8 GB RAM · integrated graphics.** Full product minus offline mode. Not a
compromised version.

### Tier 1 — Local runs, slowly
**16 GB RAM · no NVIDIA GPU, or under 6 GB VRAM.** CPU or Vulkan. Expect single-digit tokens/sec.
Fine for a short question in a brownout; not for daily work.

### Tier 2 — The measured sweet spot
**16–32 GB RAM · 8 GB VRAM (RTX 5070 Laptop, 4060, 4070).** **Measured on an RTX 5070 Laptop: about
22 tokens/sec at a 131,072-token context**, with 18 of 24 expert layers in RAM and 1.2 GB of VRAM
spare. This is where Local stops feeling like a demo. Close your browser before a long Local session:
Chrome can hold over a gigabyte of VRAM.

### Tier 3 — Comfortable
**32 GB RAM · 12–16 GB VRAM.** More of the model on the GPU, so faster. These are calculated
starting points; the installer's load test confirms them on your machine.

### Tier 4 — Everything on the GPU
**32 GB+ RAM · 20 GB+ VRAM (RTX 4090/5090).** The whole model fits in VRAM. This is the tier that can
serve a room (see `GOING-LOCAL.md`).

---

## Buying advice, honestly

- **16 GB of system RAM is the floor for Local,** because part of gpt-oss lives in RAM. 32 GB is
  noticeably better.
- **8 GB of VRAM is the practical minimum for a pleasant Local lane.** Below that, it runs mostly on
  the CPU.
- **Disk: budget 20 GB** (model 12.1 GB, engine up to 0.7 GB, voice ~1 GB, plus room).
- **The upgrade that isn't worth it:** paying for more VRAM *only* for this. Paid is better than
  any local tier.
- **The one that is:** going from no GPU to 8 GB, *if* the person genuinely loses internet often or
  can't keep a subscription going.

---

## For the classroom conversation

1. **The subscription is needed for the first install,** because the setup interview runs on Paid.
   After that, the Local lane runs without it, indefinitely.
2. **One strong machine can serve a room.** See `GOING-LOCAL.md`.
3. **The vault sits on each person's own machine** and stays there. No cloud sync, no account, no
   telemetry from the Local lane. Say it before you're asked.
