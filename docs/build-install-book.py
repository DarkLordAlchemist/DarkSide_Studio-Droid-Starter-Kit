"""Build docs/EVIE-Install-Book.pdf from the kit's own markdown.

    uv run --no-project --with markdown python docs/build-install-book.py

Needs Chrome or Edge (prints the HTML to PDF headlessly). The book is generated from INSTALL-GUIDE.md,
GOING-LOCAL.md, HARDWARE.md, TROUBLESHOOTING.md, docs/WHATS-BAKED-IN.md, so editing those and
re-running this keeps the PDF in step with the repo.
"""
import datetime, html, os, re, shutil, subprocess, sys
import markdown

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_HTML = os.path.join(ROOT, "docs", "EVIE-Install-Book.html")
OUT_PDF = os.path.join(ROOT, "docs", "EVIE-Install-Book.pdf")

CHAPTERS = [
    ("Install EVIE, step by step", "INSTALL-GUIDE.md"),
    ("The offline brain: gpt-oss-20b", "GOING-LOCAL.md"),
    ("What your PC can run", "HARDWARE.md"),
    ("When something goes wrong", "TROUBLESHOOTING.md"),
    ("What's baked in", "docs/WHATS-BAKED-IN.md"),
]

MEMORY_CHAPTER = """
# How EVIE's memory works

EVIE's memory is a folder of plain text files on your PC, `EVIE\\Vault`, run like a small wiki
(after Andrej Karpathy's "LLM wiki" idea). She doesn't re-read everything every time. She keeps a
tidy set of linked pages up to date, the way a good assistant keeps a binder.

| Part | What it does |
|---|---|
| `raw\\` | Your sources: handouts, articles, briefs. She reads them and **never edits them**. |
| The pages | Subjects, projects, routines, reference. She writes these and keeps them current. |
| `index.md` | The catalog: every page, one line each. She reads it first. |
| `log.md` | The timeline: an entry **before and after** every task that changes files. Never edited. |
| `VAULT-INDEX.md` | The rules: cite sources, mark guesses, label thin evidence, mark old claims outdated, never delete. |
| `GUARDRAILS.md` | The safety rules you agreed in the interview. |

**Three things you can ask for:**

- **"Ingest this"**: drop a file in `raw\\` and she summarises it, updates every related page, flags
  anything that contradicts what she knew, and logs it.
- **A question**: she looks it up in the index, answers from her pages, and tells you which ones.
  Good answers get filed in `outputs\\`.
- **"Check the vault"**: a health check that finds broken links, forgotten pages, duplicates and
  stale notes, and tidies them, without deleting anything.

**Two safety hooks run automatically:**

- **Delete protection**: any command that would delete or move files inside your EVIE folder stops
  and asks you first.
- **Compaction sweep**: when a long conversation gets compressed, she marks it in the log, re-reads her
  rules, and saves any lesson that would otherwise be lost.
"""

CSS = """
@page { size: A4; margin: 18mm 16mm 20mm 16mm; }
* { box-sizing: border-box; }
body { font-family: "Segoe UI", Arial, sans-serif; font-size: 10.4pt; line-height: 1.5; color: #1d1d1f; }
h1 { font-size: 21pt; color: #13294b; border-bottom: 3px solid #c0392b; padding-bottom: 6px; margin-top: 0; page-break-before: always; }
h1.first { page-break-before: avoid; }
h2 { font-size: 14pt; color: #13294b; margin-top: 20px; page-break-after: avoid; }
h3 { font-size: 11.5pt; color: #2c3e50; page-break-after: avoid; }
p, li { orphans: 3; widows: 3; }
code { font-family: Consolas, monospace; font-size: 9.2pt; background: #f2f4f7; padding: 1px 4px; border-radius: 3px; }
pre { background: #0f1b2d; color: #e8edf5; padding: 10px 12px; border-radius: 6px; white-space: pre-wrap; word-break: break-all; page-break-inside: avoid; }
pre code { background: none; color: inherit; padding: 0; font-size: 9pt; }
table { border-collapse: collapse; width: 100%; margin: 10px 0; font-size: 9.2pt; page-break-inside: auto; }
tr { page-break-inside: avoid; }
th { background: #13294b; color: #fff; text-align: left; padding: 6px 7px; }
th code { background: rgba(255,255,255,.18); color: #fff; }
td { border-bottom: 1px solid #dde2ea; padding: 5px 7px; vertical-align: top; }
tr:nth-child(even) td { background: #f7f9fc; }
blockquote { border-left: 4px solid #c0392b; background: #fdf3f2; margin: 10px 0; padding: 6px 12px; }
.cover { height: 250mm; display: flex; flex-direction: column; justify-content: center; text-align: center; }
.cover .brand { letter-spacing: 3px; color: #c0392b; font-weight: 700; font-size: 11pt; }
.cover .title { font-size: 34pt; font-weight: 800; color: #13294b; margin: 14px 0 6px; }
.cover .sub { font-size: 14pt; color: #34495e; }
.cover .meta { margin-top: 40px; font-size: 10pt; color: #7f8c8d; }
.cover .line { margin: 26px auto; width: 120px; border-top: 3px solid #c0392b; }
.cover .oneline { margin: 34px auto 0; max-width: 150mm; text-align: left; }
.toc { page-break-before: always; }
.toc li { margin: 6px 0; font-size: 11.5pt; }
"""

def md_to_html(text):
    text = re.sub(r"<details>.*?</details>", "", text, flags=re.S)
    return markdown.markdown(text, extensions=["tables", "fenced_code", "sane_lists"])

def chapter_html(title, md_text):
    md_text = re.sub(r"\A#\s+.*\n", "", md_text.lstrip())       # drop the file's own H1
    md_text = re.sub(r"^> \*\*AI:\*\*.*?(?=\n\n)", "", md_text, flags=re.S | re.M)  # drop AI-addressed notes
    return f'<h1>{html.escape(title)}</h1>\n' + md_to_html(md_text)

def main():
    today = datetime.date.today().isoformat()
    parts = []
    parts.append(f"""<div class="cover">
      <div class="brand">DARKSIDE STUDIO &middot; DROID STARTER KIT</div>
      <div class="title">EVIE Install Book</div>
      <div class="sub">Claude Code &middot; LLM-wiki memory &middot; Paid + offline gpt-oss &middot; voice</div>
      <div class="line"></div>
      <div class="oneline">
        <p><b>The whole install is one line</b> in Windows PowerShell:</p>
        <pre><code>irm https://raw.githubusercontent.com/DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit/main/install.ps1 | iex</code></pre>
        <p>You need a Claude subscription for this first install. After that, the Local shortcuts run
        on gpt-oss-20b with no internet, no subscription, and no sign-in, ever.</p>
      </div>
      <div class="meta">Version 2 &middot; {today}</div>
    </div>""")
    toc = ["Install EVIE, step by step", "How EVIE's memory works"] + [c[0] for c in CHAPTERS[1:]]
    parts.append('<div class="toc"><h1 class="first">Contents</h1><ol>' + "".join(f"<li>{html.escape(t)}</li>" for t in toc) + "</ol></div>")
    first = CHAPTERS[0]
    parts.append(chapter_html(first[0], open(os.path.join(ROOT, first[1]), encoding="utf-8").read()))
    parts.append(chapter_html("How EVIE's memory works", MEMORY_CHAPTER))
    for title, path in CHAPTERS[1:]:
        parts.append(chapter_html(title, open(os.path.join(ROOT, path), encoding="utf-8").read()))
    doc = f"<!doctype html><html><head><meta charset='utf-8'><title>EVIE Install Book</title><style>{CSS}</style></head><body>{''.join(parts)}</body></html>"
    with open(OUT_HTML, "w", encoding="utf-8") as f:
        f.write(doc)

    browser = next((p for p in [r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                                r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
                                shutil.which("chrome"), shutil.which("msedge")] if p and os.path.exists(p)), None)
    if not browser:
        sys.exit("Chrome or Edge not found - open docs/EVIE-Install-Book.html and print it to PDF instead.")
    url = "file:///" + OUT_HTML.replace("\\", "/")
    subprocess.run([browser, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                    f"--print-to-pdf={OUT_PDF}", url], check=True, timeout=180)
    print("wrote", OUT_PDF, os.path.getsize(OUT_PDF), "bytes")

if __name__ == "__main__":
    main()
