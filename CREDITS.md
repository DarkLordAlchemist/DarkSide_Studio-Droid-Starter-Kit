# Credits and licensing

## The short version

This repository is licensed **Apache 2.0**. You can use it, teach with it, sell services around it,
fork it, and build closed-source products on top of it. Keep the `LICENSE` and `NOTICE` files with
it and you have met every obligation.

It does **not** contain anyone else's code or text.

---

## Where the ideas came from

The design of this module owes a real debt to [Jared Rhodenizer's](https://jaredrhod.com) work —
specifically [ai-memory-vault](https://github.com/jaredrhod/ai-memory-vault), which demonstrated that
an AI's long-term memory can be a folder of plain markdown files rather than a vector database, and
[backtalk](https://github.com/jaredrhod/backtalk), which is the voice loop this module installs.

Two things are worth being precise about, because they are different in kind:

**Ideas are not owned.** A boot-config file that carries an agent's identity, a vault of notes with
folder indexes, per-task notes that tell the AI what to read first, a push-to-talk voice loop — these
are architectural ideas, and copyright does not cover them. Anyone may build their own version.

**Text and code are owned.** Copying his template files, his prose, or his phrasing would make this
an adaptation of his work, and CC BY-SA 4.0 would then require this entire repository to carry that
same license and forbid closed-source use downstream.

Every file in this repository is written from scratch for this module. The structure of the templates
follows a general pattern he demonstrated; the words, the guardrails, the interview, the batch
launchers, the tuning script, and the documentation are original. That is what makes Apache 2.0
available rather than mandatory share-alike.

**Two rules for anyone maintaining this going forward:**

1. **Do not paste text from his repositories into these files.** Not a rule you like the wording of,
   not a paragraph from a README. Read it, understand it, write your own. The moment his prose lands
   in this repo, this repo becomes CC BY-SA and Apache 2.0 no longer applies.
2. **Do not vendor `backtalk` into this repository.** Setup clones it from its own repo, which keeps
   the AGPL boundary clean. Copying its source in here would put this entire repository under AGPL.

Attribution is not legally required in this arrangement. It is here because it is accurate and
because the work deserves it.

---

## Why Apache 2.0

For a module that will be taught in classrooms and shown alongside a commercial hardware partner,
Apache 2.0 is the least troublesome choice available:

- **Permissive.** A school, a student, or a business can adapt it without inheriting obligations.
- **Explicit patent grant.** Contributors grant patent rights along with copyright. MIT is silent on
  this; for anything with an institutional or commercial partner attached, silence is a liability.
- **Explicit attribution mechanism.** The `NOTICE` file is a standard, machine-readable place for
  credits — and companies that review licenses know exactly what it means, which shortens
  conversations with legal departments.
- **Universally recognised.** Nobody has to ask what it means.

MIT would also be fine and is shorter. CC BY-SA would force every downstream user to open-source
their adaptations, which is a poor fit for a business audience. GPL/AGPL would be worse for the same
reason.

---

## What the setup installs, and under what terms

None of this ships in the repository. All of it is downloaded from its own source at install time,
by the user, onto their own machine.

| Component | License | Note |
|---|---|---|
| Claude Code | Proprietary (Anthropic) | Requires a paid subscription. Cloud mode only. |
| backtalk | AGPL-3.0-or-later | Cloned unmodified from its own repository. |
| Ollama | MIT | Local inference server. |
| Ornith 1.5 9B | MIT | The local model. |
| Kokoro | Apache-2.0 | Text to speech. Runs locally. |
| faster-whisper / Whisper | MIT | Speech to text. Runs locally. |
| espeak-ng | GPL-3.0 | Used as an external command-line tool, not linked. |

**Why "installed, not distributed" matters.** Telling a user to download a program is not the same as
distributing that program. AGPL obligations attach to whoever distributes or hosts the software — so
they sit with backtalk's own repository, not with this one. If you ever change that by bundling
backtalk in a zip you hand out, the obligations move to you.

---

## Practical steps before publishing

1. Put your real name or your institution's name in `LICENSE` and `NOTICE` where it says `Ross`.
2. Set the repository's license field to `Apache-2.0` on GitHub so the badge and the sidebar are
   correct.
3. Keep this file. It is the record of the reasoning, and future-you will want it.
4. If a student or colleague contributes, Apache 2.0 already covers their contribution — no CLA
   needed for a project this size.
5. If you use "EVIE" commercially with PC Express, a name is a trademark question, not a copyright
   one, and it is separate from all of the above. Worth a search before anything gets printed.

*None of this is legal advice. It is a considered reading of standard open-source licenses. If the
partnership grows past a classroom pilot, have it looked at by someone qualified — an hour of a
lawyer's time before launch is cheaper than the alternative.*
