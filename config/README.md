# config/

**There is no mode switch file.** Which brain EVIE uses is decided by which shortcut you
double-click. `scripts\evie-env.cmd` takes `paid` or `local`, each launcher passes its own, and
everything it sets lives only in that one window. That's why a Paid window and a Local window can
be open side by side without affecting each other.

---

**backtalk.json.example**: the voice settings. Setup copies it to `..\..\backtalk\backtalk.json`.

| Key | What it does |
|---|---|
| `agent_dir` | The folder holding EVIE's `CLAUDE.md`. This is what makes the voice *EVIE*. **Written by the Talk launchers on every start**, so you don't have to set it. |
| `model`, `deep_model` | Which brain the voice uses. **Also written by the Talk launchers on every start** (Claude for Paid, gpt-oss for Local). A stale value left here once made the voice go silent with no error, which is why the launchers rewrite it. |
| `name` | What she's called on screen. |
| `ptt_key` | Push-to-talk key. `home` by default. `insert` and `scroll_lock` also work. Avoid any key you type with. |
| `voice` | Kokoro voice. **Default `af_heart,af_bella`**: a blend of Heart and Bella, chosen by ear because it sounded the most human of six options. A comma between voices blends them. Single voices also work: `af_heart`, `af_bella`, `af_nicole`, `bf_emma` (British), `am_michael`, `bm_lewis`. Keep the first letter (language) the same across a blend. |
| `speed` | Speaking pace. **Default `0.95`** (slightly unhurried, which sounds more natural). Sane range is about 0.8 to 1.2. |
| `stt_model` | Whisper model for hearing you. `small.en` is the sweet spot on a laptop. |
| `permission_mode` | `ask` (she asks out loud before acting) or `bypassPermissions` (she acts without asking, and the guardrails hold the line). |
| `extra_dirs` | Other folders the voice may work in besides `agent_dir`. |

---

## The local brain's settings are not in this folder

They live in `EVIE\local\brain.cmd`, written by `scripts\Install-LocalBrain.ps1` for **this**
machine's hardware: context size, how much of gpt-oss sits in RAM vs VRAM, the port. Re-run that
script if the hardware changes, rather than editing the file by hand.
