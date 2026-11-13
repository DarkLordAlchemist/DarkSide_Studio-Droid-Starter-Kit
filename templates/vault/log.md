# log — the timeline

Append-only. Every change to the vault, and every task that changes files, gets an entry here.
Old entries are never edited; if one was wrong, a new entry corrects it.

Format (keep the prefix exact, so it can be searched):

```
## [YYYY-MM-DD] <op> | <short title>
- what changed (links), what was checked, what's still open
```

`<op>` is one of: `start`, `done`, `ingest`, `query`, `lint`, `update`, `session`.
**Before** a task that changes files, EVIE writes a `start` entry. **After** it, she writes a `done` entry.

## [{{DATE}}] start | EVIE set up
- Vault created by Setup-EvieHome.ps1. The interview answers fill Profile, VAULT-INDEX, GUARDRAILS and CLAUDE.md.
