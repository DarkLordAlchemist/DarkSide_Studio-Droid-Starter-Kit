# Vault Index

**This file lives at the root of your vault. It is EVIE's operating manual for your memory.**

EVIE reads this at the start of every session, right after her boot config. It answers three
questions: who you are, what's in this vault, and how you like to work.

> **AI:** if `[FILL IN: ...]` markers remain, setup isn't finished. Offer to fill them in.

---

## Who I am

- **Name:** [FILL IN]
- **What I do:** [FILL IN: e.g. "Grade 12 STEM student at ___" or "I run a 4-person print shop"]
- **Timezone / where I am:** [FILL IN]
- **What a normal week looks like:** [FILL IN: classes, shifts, standing commitments]
- **What I want EVIE for, in one sentence:** [FILL IN]

The full version lives in `Profile.md`. EVIE keeps that current as she learns things — this section
is the summary she reads first.

---

## Vault structure

```
Vault/
├── VAULT-INDEX.md          You are here. The map.
├── GUARDRAILS.md           The rules. Read every session.
├── Profile.md              Who I am, kept current by EVIE.
├── Active Priorities.md    What's open right now. The first thing EVIE checks.
├── 01 - Daily Notes/       One note per day. The running log.
│   ├── Daily Note Template.md
│   └── NN - Month YYYY/    e.g. "09 - September 2026"
│       └── YYYY-MM-DD.md
├── 02 - Subjects/          One folder per class (students) or per client/area (business)
│   └── <Subject>/
│       ├── <Subject>.md    The folder index. Always current.
│       ├── Notes/
│       ├── Assessments/
│       └── Reference/
├── 03 - Projects/          Anything with a deadline and an end state
│   └── <Project>/
├── 04 - Routines/          Recurring tasks, one note each. See below.
└── 05 - Reference/         Everything that isn't tied to a subject or project
```

**Folder indexes.** Every folder has a `<Folder Name>.md` inside it listing what's in it and why.
When EVIE creates, renames, moves, or materially changes a note, she updates that index in the same
breath. A note the map doesn't show is a note no future session finds.

---

## Routines — teaching EVIE a recurring task once

A **Routine** is a single note covering one thing you do repeatedly. Its job is to tell EVIE which
notes to open before she starts, so she arrives at the task already holding the right context instead
of guessing at it. Most people never build these, and it is the difference between an assistant that
is generically capable and one that does *your* work *your* way.

Each Routine note has four parts:

1. **When this runs** — the trigger. "Every Sunday night." "Whenever a new assignment is posted."
2. **Read first** — the specific notes EVIE loads before starting. Three to six links, not twenty.
3. **The steps** — what she does, in order.
4. **What good looks like** — an example of the finished output, or a rule that catches the usual mistake.

Starter Routines worth building in week one:

- `Weekly Planning.md` — Sunday: pull every deadline from every subject folder into one list, ranked
- `New Assignment Intake.md` — turn a posted brief into a project folder, a deadline, and a first step
- `Lecture Capture.md` — turn today's messy notes into a clean note plus five quiz questions
- `Exam Prep.md` — build a study plan and a question bank from a specific set of notes

Business equivalents: `Weekly Review.md`, `New Client Intake.md`, `Invoice Run.md`, `Meeting Notes to Actions.md`.

---

## Daily notes

Live in `01 - Daily Notes/`, in monthly subfolders named `NN - Month YYYY`, filename `YYYY-MM-DD.md`.
Every daily note is created from `Daily Note Template.md` — never hand-rolled. If today's note already
exists, EVIE appends a new `## Session N` rather than overwriting.

Daily notes are an append-only log. They are the *record* of what happened, never the *documentation*
of what a thing is. Anything durable also gets a real home in a real folder.

---

## How I like to work with EVIE

- **Length:** [FILL IN: e.g. "short by default, long when I ask"]
- **Tone:** [FILL IN]
- **Things that annoy me:** [FILL IN: e.g. "restating my question back to me before answering"]
- **When I'm stuck I want:** [FILL IN: e.g. "questions, not answers" / "just tell me"]
- **Off-limits folders:** [FILL IN]

---

*Part of the EVIE companion module. See `CREDITS.md` for the projects that inspired this design.*
