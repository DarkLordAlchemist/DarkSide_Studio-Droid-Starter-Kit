# Vault Index — how EVIE's memory works

**This file lives at the root of your vault. It is the rulebook for EVIE's memory.**
EVIE reads it at the start of every session, right after her boot config.

> **AI:** if `[FILL IN: ...]` markers remain, setup isn't finished. Offer to fill them in.

---

## Who I am

- **Name:** [FILL IN]
- **What I do:** [FILL IN: e.g. "Grade 12 STEM student at ___" or "I run a 4-person print shop"]
- **Timezone / where I am:** [FILL IN]
- **What a normal week looks like:** [FILL IN: classes, shifts, standing commitments]
- **What I want EVIE for, in one sentence:** [FILL IN]

The full version lives in `Profile.md`, which EVIE keeps current.

---

## The idea: a wiki EVIE maintains

This vault follows Andrej Karpathy's "LLM wiki" pattern. The model doesn't re-read every document
every time you ask something. Instead it **compiles** what it learns into a small wiki of linked
pages, keeps that wiki current, and checks it for problems now and then. You curate the sources and
ask the questions. EVIE does the bookkeeping.

**Three layers:**

| Layer | Where | Rule |
|---|---|---|
| **Sources** | `raw/` (+ `raw/assets/` for images and PDFs) | Drop anything here: notes, handouts, articles, briefs. **EVIE reads them and never edits them.** |
| **The wiki** | every other folder | Pages EVIE writes and keeps current. You can edit anything. |
| **The rules** | this file, `GUARDRAILS.md`, and `CLAUDE.md` one level up | How the whole thing works. |

**Three special files:**

- **`index.md`** is the catalog: **every page, one line each**, grouped by type. EVIE reads it first
  when answering anything, and updates it whenever a page is added. A page that isn't in the index
  doesn't exist as far as the next session is concerned.
- **`log.md`** is the timeline. It's append-only: every change gets one entry, `## [YYYY-MM-DD] op | title`.
  It's never edited, only added to.
- **Daily notes** (`01 - Daily Notes/`) are the story of a day. The log is the record of events, and
  the daily note is the narrative. EVIE writes both.

---

## What EVIE does with it

- **Ingest:** you drop a file in `raw/`, or hand one over, and say "ingest this". EVIE reads all of
  it, tells you the 3–5 takeaways, writes or updates a summary page that cites the source, updates
  every related page, flags anything that contradicts what the vault already says, adds new pages to
  `index.md`, and logs it. **One source at a time.**
- **Query:** EVIE reads `index.md`, opens the relevant pages, and answers, saying which pages the
  answer came from. If the answer is worth keeping, she files it in `outputs/` and indexes it.
- **Lint:** a health check, run when you ask or about once a week. The checker script finds broken
  links, orphan pages, and pages missing from the index. EVIE then does a judgment pass: claims that
  contradict each other, out-of-date status lines, duplicate notes to merge, and pages that have grown
  too big. The playbook is the `wiki` skill in `.claude\skills\wiki\SKILL.md`.

---

## Page rules

1. **One topic per page.** Update the existing page instead of making a second one. Search first.
2. **Cite where things came from.** Every claim traces to a file in `raw/`, a link, a daily note, or
   something EVIE checked herself. Mark claims that matter `(extracted)` (stated in a source),
   `(inferred)` (EVIE's own reasoning), or `(verified)` (EVIE checked it).
3. **No source, no number.** No figure, date, price or statistic goes in without a citation next to it.
4. **Thin evidence is an "early signal",** not a fact. One source, one example, or a partial read gets
   labelled that way until more evidence comes in.
5. **Outdated claims are marked, never deleted:** `> [!outdated] (date): what changed, now see …`.
   That way, nobody re-learns an old claim as if it were current.
6. **Contradictions are flagged, never silently overwritten:** `> [!warning] Contradiction (date): …`.
7. **Link pages with `[[page-name]]`.** Link generously.
8. **Keep pages small.** A page over ~500 lines gets split into a short hub page plus sub-pages, with
   the original copied to `Archive/` first. Big files bury the current state and cost EVIE context.
9. **The memory filter.** Before saving anything to memory (`Profile.md`, `feedback/`, this file), EVIE
   asks: *will this change how I behave in future?* If not, it goes only in the daily note. If yes,
   she writes **why** (what went wrong), **how** (what to do next time), the **date**, and the
   **source**. If it's about a task that repeats, she fixes that task's Routine or skill too.
10. **Never delete or move a page.** Superseded pages get copied to `Archive/` or marked
    `status: superseded → [[new-page]]`.

---

## Vault structure

```
Vault/
├── VAULT-INDEX.md          This file. The rules.
├── index.md                The catalog: every page, one line each.
├── log.md                  The timeline: every change, append-only.
├── GUARDRAILS.md           The safety rules. Read every session.
├── Profile.md              Who I am, kept current by EVIE.
├── Active Priorities.md    What's open right now. The first thing EVIE checks.
├── raw/                    Sources you hand over. Read, never edited.
├── outputs/                Answers worth keeping, filed back in.
├── feedback/               Lessons about how EVIE should work (one per file).
├── 01 - Daily Notes/       One note per day: NN - Month YYYY/YYYY-MM-DD.md
├── 02 - Subjects/          One folder per class (students) or per client/area (business)
├── 03 - Projects/          Anything with a deadline and an end state
├── 04 - Routines/          Recurring tasks, one note each (see below)
├── 05 - Reference/         Everything else worth looking up again
└── Archive/                Snapshots of superseded pages
```

---

## Routines: teach EVIE a recurring task once

A **Routine** is one note per thing you do repeatedly. It tells EVIE which notes to open before she
starts, so she begins with the right context instead of guessing. Each one has four parts:

1. **When this runs:** the trigger ("every Sunday night").
2. **Read first:** the 3–6 notes EVIE loads before starting.
3. **The steps:** what she does, in order.
4. **What good looks like:** an example of the finished result, or a rule that catches the usual mistake.

The fastest way to make one is to **do the task with EVIE once, then say "turn what we just did
into a Routine."** She writes it from what actually happened.

Starter Routines: `Weekly Planning`, `New Assignment Intake`, `Lecture Capture`, `Exam Prep`.
Business: `Weekly Review`, `New Client Intake`, `Invoice Run`, `Meeting Notes to Actions`.

---

## How I like to work with EVIE

- **Length:** [FILL IN: e.g. "short by default, long when I ask"]
- **Tone:** [FILL IN]
- **Things that annoy me:** [FILL IN]
- **When I'm stuck I want:** [FILL IN: "questions, not answers" / "just tell me"]
- **Off-limits folders:** [FILL IN]

---

*Part of the EVIE companion module. The wiki pattern is after Andrej Karpathy's "LLM wiki" idea; see
`CREDITS.md`.*
