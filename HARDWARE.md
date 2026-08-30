# What each machine can actually run

Written for the conversation where a student asks "which laptop do I need?" The honest answer has two
halves, and the first half is free.

---

## Nobody needs a GPU for Phase 1

EVIE in Cloud mode runs on a subscription, not on the laptop. The model lives on Anthropic's servers.
Chat and Talk both work on a machine with integrated graphics and 8 GB of RAM — the requirements are
Windows 10 1809 or newer, 4 GB of RAM, and an internet connection.

**Everything in Tier 1 of `USE-CASES.md` — the deadline tracking, the notes-to-quiz pipeline, the
recall drilling, the feedback on drafts — works fully on a machine with no graphics card at all.**

Say this plainly and first. A student who can't afford a gaming laptop should not walk away thinking
this isn't for them. It is, and it's the better half of the product.

The GPU buys one thing: the ability to keep working when the internet doesn't.

---

## The tiers

Context values are what `Set-OllamaTuning.ps1` will choose. Speeds are `ornith-1.5:9b` at Q4, rough
and hardware-dependent — treat them as the shape, not a spec sheet.

### Tier 0 — Cloud only
**Any Windows laptop · 8 GB RAM · integrated graphics**

Chat and Talk on Claude. No local model. Needs internet.

Everything in Tier 1 of `USE-CASES.md`, plus research and long-form work, which are the things a
local model is worst at anyway. **This tier is not a compromised version of the product.** It's the
full product minus offline capability.

### Tier 1 — Local, but only just
**16 GB RAM · 6 GB VRAM (RTX 4050, 3050)**

Context: 16,384. Roughly 10–18 tokens/sec.

Local mode runs. Short jobs only: capture a note, quiz me on Unit 3, file these downloads, what's due
this week. Anything past four or five steps will drift. Real work stays in Cloud.

Worth it if connectivity is genuinely unreliable. Not worth paying up for otherwise.

### Tier 2 — The sweet spot
**16 GB RAM · 8 GB VRAM (RTX 5070 laptop, 4060, 4070)**

Context: 32,768. Roughly 15–25 tokens/sec.

The model doesn't quite fit alongside a 32K context, so some layers run from system RAM. It still
works and it's the point where local mode stops feeling like a demo. Most of the Tier 1 use cases
run offline; long research and multi-step work stay in Cloud.

**This is the tier to recommend by default** for a student who wants the offline half. Close your
browser before a long local session — Chrome can hold over a gigabyte of VRAM and it's the cheapest
speedup available.

### Tier 3 — Comfortable
**32 GB RAM · 12–16 GB VRAM (RTX 5070 Ti, 4080 laptop)**

Context: 65,536–131,072. Roughly 30–45 tokens/sec.

Everything fits in VRAM. Long sessions hold together, and local mode becomes a genuine daily driver
rather than a fallback.

### Tier 4 — Desktop or workstation
**64 GB+ RAM · 24 GB+ VRAM (RTX 5090, 4090)**

Context: 262,144, the model's maximum. 50+ tokens/sec, and `ornith-1.5:35b` becomes an option — a
real step up in capability, not just speed.

Also the tier that can serve a room. See the LAN section in `GOING-LOCAL.md`.

---

## Buying advice, honestly

**VRAM first, everything else second.** An 8 GB card with 16 GB of system RAM beats a 6 GB card with
32 GB for this workload every time. VRAM is what the model sits in; RAM is where it spills when the
VRAM runs out, and spilling is the thing that makes it slow.

**16 GB of system RAM is the floor**, not because the model needs it but because Windows, a browser,
and a spilled model together will not fit in 8.

**Disk: budget 20 GB.** Claude Code and the voice models are small; the local model is 6.6 GB and you
will end up with a second one to compare against.

**The upgrade that isn't worth it:** paying up from 8 GB to 12 GB of VRAM purely for this. The
difference is real but it's the difference between "local mode works" and "local mode works
comfortably" — and Cloud mode is better than both. Spend it on RAM or an SSD instead.

**The upgrade that is:** going from no discrete GPU to 8 GB, *if and only if* the student genuinely
loses internet often. If they don't, that money buys about three years of Claude subscription.

---

## For the classroom conversation

Three things worth saying out loud when this is presented alongside hardware:

1. **The subscription is the real barrier, not the laptop.** Every student needs their own Claude
   account for Phase 1. Sort that out before hardware, because a great laptop with no subscription
   does less than a cheap laptop with one.

2. **One shared machine can serve a room.** A single Tier 4 desktop running Ollama on the LAN gives a
   whole class offline access without every student needing a GPU. Their vaults stay on their own
   machines; only the inference is shared. `GOING-LOCAL.md` has the setup.

3. **The vault sits on the student's own machine and stays there.** No cloud sync, no account, no
   telemetry. Parents and administrators assume the opposite about anything with "AI" on it, and this
   is the strongest thing about the design — say it before you're asked.
