---
name: wiki
description: Maintain EVIE's vault as an LLM wiki. Use when the person says ingest/add/read this source, asks a question the vault should answer, asks for a vault check or cleanup, or at the start and end of any task that changes files (logging).
---

# Wiki playbook

The rules live in `Vault/VAULT-INDEX.md`. This is how to carry them out.
Every operation ends with an entry in `Vault/log.md`.

## Logging (every task that changes files)
1. **Before touching anything**, append `## [YYYY-MM-DD] start | <task>` to `Vault/log.md`, with
   bullets for the plan and what will be touched. Check the real date first.
2. Do the work.
3. **After**, append `## [YYYY-MM-DD] done | <task>`, with bullets for what changed, how it was
   checked, and what's still open.
4. Add the story to today's daily note, and new pages to `Vault/index.md`.

## Ingest (one source at a time)
1. Log `start | ingest <source>`. Save the source in `raw/` as `YYYY-MM-DD-name.ext` if it isn't there.
2. **Read the whole source.** Never skim.
3. Tell the person the 3–5 takeaways, what's new compared with the vault, and anything that
   contradicts it. (In a voice session, say this as plain sentences.)
4. Write or update the summary page in the right folder, citing `raw/<file>`. Mark claims
   `(extracted)`, `(inferred)` or `(verified)`. Thin evidence is labelled `early signal`.
5. Update every related page with the new fact plus a citation, and add `[[links]]` both ways.
6. Flag contradictions with `> [!warning] Contradiction (date): …` and never overwrite silently.
7. Add new pages to `index.md`. Log `done | ingest <source>`, listing every page touched.

## Query
1. Read `index.md`, then the pages it points to (search the vault for anything it missed).
2. Answer, naming the pages used. If the vault doesn't know, say so and offer to find out.
3. If the answer is worth keeping, file it in `outputs/YYYY-MM-DD-name.md`, index it, and log it.

## Lint (on request, or about weekly)
1. Log `start | lint`. Run the checker (it only reads, never changes anything):
   `uv run --no-project python "<EVIE>\droid-kit\scripts\wiki-lint.py" "<EVIE>\Vault"`
2. Judgment pass: numbers with no source, claims that should be marked `early signal` or
   `[!outdated]`, contradictions between pages, open items the daily notes show as done.
3. **Sleep pass:** merge duplicate notes (the newest confirmed version wins, and the others get
   `status: superseded → [[kept]]`), boil a pile of small lessons down into one clean rule, move
   anything that won't change future behavior into the daily note, and split any page over ~500
   lines into a hub plus sub-pages (copy the original to `Archive/` first).
4. Fix the safe things (missing index lines, links). Report anything that needs the person's call.
   **Never delete or move a page.** Log `done | lint`, with the counts before and after.

## Turning a job into a skill or Routine
After a one-off job goes well, offer: "Want me to turn what we just did into a Routine?" Write it
from what actually happened (trigger, read-first notes, steps, what good looks like). Test it on
2–3 past examples, and turn every miss into a line in it.
