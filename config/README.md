# config/

**There is no mode switch file any more.** Which brain EVIE uses is decided by which shortcut you
double-click. `scripts\evie-env.cmd` takes `cloud` or `local` as an argument, and each launcher
passes its own. That means a Cloud window and a Local window can be open side by side and neither
can affect the other.

---

**backtalk.json.example** — the voice settings. During setup this gets copied to
`..\..\backtalk\backtalk.json` with real paths filled in.

| Key | What it does |
|---|---|
| `agent_dir` | The folder holding EVIE's `CLAUDE.md`. This is what makes the voice *EVIE* rather than a generic assistant. Absolute Windows path, doubled backslashes. |
| `name` | What she's called on screen. |
| `ptt_key` | Push-to-talk key. `home` by default because nothing else uses it. `insert` and `scroll_lock` also work. Avoid anything you type with. |
| `voice` | Kokoro voice ID. Ships as `af_heart` — "Heart", American English, warm and even. First letter is the language: `a` American, `b` British. Around 60 voices ship free. |
| `stt_model` | Whisper model for hearing you. `small.en` is the sweet spot on a laptop. `base.en` is faster and worse, `medium.en` slower and better. |

**Other voices worth trying:** `af_bella` (brighter), `af_nicole` (softer), `bf_emma` (British),
`am_michael` / `bm_lewis` (male).

---

## Ollama settings are not in this folder

They can't be. Ollama runs as a background Windows service and reads its configuration when *it*
starts, not when a terminal or a batch file starts — so `OLLAMA_CONTEXT_LENGTH` has to live in your
Windows user environment variables.

`scripts\Set-OllamaTuning.ps1` measures your machine, picks the largest context window it can
sustain, writes all of it, restarts Ollama, and then times a real answer to prove it worked. Run
that instead of setting anything by hand.
