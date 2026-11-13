"""Read-only health check for EVIE's vault (Karpathy-style LLM wiki).

Reports:
  - broken links    : [[wikilinks]] / relative .md links that resolve to nothing
  - orphans         : pages no other page links to
  - not in index    : pages index.md doesn't list
  - un-ingested raw : files in raw/ no wiki page references

It never modifies anything.
Usage:  uv run --no-project python wiki-lint.py <vault_path>
"""
import os
import re
import sys
from urllib.parse import unquote

VAULT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "..", "Vault"))
SKIP_DIRS = {".obsidian", ".git", ".trash"}
# Pages that are structural and don't need inbound links / index lines.
STRUCTURAL = {"index.md", "log.md", "VAULT-INDEX.md", "README.md", "Daily Note Template.md"}

WIKILINK = re.compile(r"\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]")
MDLINK = re.compile(r"\]\(([^)\s]+?)\)")
FENCE = re.compile(r"```.*?```", re.S)
INLINE_CODE = re.compile(r"`[^`\n]*`")


def rel(p):
    return os.path.relpath(p, VAULT).replace("\\", "/")


def collect():
    pages, raws = [], []
    for root, dirs, files in os.walk(VAULT):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for f in files:
            full = os.path.join(root, f)
            r = rel(full)
            if r.startswith("raw/"):
                if f != "README.md":
                    raws.append(r)
            elif f.endswith(".md"):
                pages.append(r)
    return sorted(pages), sorted(raws)


def frontmatter_names(text):
    names = set()
    if text.startswith("---"):
        end = text.find("\n---", 3)
        if end > 0:
            fm = text[3:end]
            for m in re.finditer(r"^\s*(?:name|title):\s*['\"]?([^'\"\n]+)", fm, re.M):
                names.add(m.group(1).strip().lower())
            in_alias = False
            for line in fm.splitlines():
                if re.match(r"^\s*aliases:", line):
                    in_alias = True
                    continue
                if in_alias:
                    m = re.match(r"^\s*-\s*(.+)", line)
                    if m:
                        names.add(m.group(1).strip().strip("'\"").lower())
                    elif line.strip():
                        in_alias = False
    return names


def main():
    pages, raws = collect()
    texts = {p: open(os.path.join(VAULT, p), encoding="utf-8", errors="replace").read() for p in pages}

    # name -> page lookup for [[wikilinks]]
    lookup = {}
    for p in pages:
        stem = os.path.splitext(os.path.basename(p))[0].lower()
        lookup.setdefault(stem, p)
        lookup.setdefault(os.path.splitext(p)[0].lower(), p)
        for n in frontmatter_names(texts[p]):
            lookup.setdefault(n, p)

    inbound = {p: set() for p in pages}
    referenced_raw = set()
    broken = []

    for p, text in texts.items():
        if p.startswith("Archive/"):
            continue  # frozen snapshots: their relative links are expected to break
        body = INLINE_CODE.sub("", FENCE.sub("", text))
        for m in WIKILINK.finditer(body):
            target = m.group(1).strip().lower().removesuffix(".md")
            hit = lookup.get(target)
            if hit:
                if hit != p:
                    inbound[hit].add(p)
            elif target.startswith("raw/"):
                referenced_raw.add(target)
            else:
                broken.append((p, "[[" + m.group(1) + "]]"))
        for m in MDLINK.finditer(body):
            href = unquote(m.group(1).split("#")[0])
            if not href or "://" in href or href.startswith("mailto:"):
                continue
            target = os.path.normpath(os.path.join(VAULT, os.path.dirname(p), href))
            if not target.startswith(VAULT):
                continue  # points outside the vault (e.g. ../my-agent); not ours to check
            r = rel(target)
            if os.path.isdir(target):
                continue
            if r in inbound:
                if r != p:
                    inbound[r].add(p)
            elif os.path.exists(target):
                if r.startswith("raw/"):
                    referenced_raw.add(r.lower())
            else:
                broken.append((p, href))
        # bare mentions like raw/2026-11-12-foo.md also count as citations
        for m in re.finditer(r"raw/[\w./ -]+\.\w+", text):
            referenced_raw.add(m.group(0).lower())

    # A page counts as indexed if index.md links it, or if a sub-catalog that index.md links does
    # (a page with `catalog: true` in its frontmatter, e.g. a series hub with hundreds of items).
    catalogs = {"index.md"} | {q for q in pages if "index.md" in inbound[q]
                               and re.search(r"^catalog:\s*true\s*$", texts[q].split("\n---", 1)[0], re.M)}
    index_targets = {q for q in pages if inbound[q] & catalogs}

    orphans = [p for p in pages if not inbound[p] and os.path.basename(p) not in STRUCTURAL
               and not p.startswith("01 - Daily Notes/")]
    not_indexed = [p for p in pages if p not in index_targets and p != "index.md"
                   and os.path.basename(p) != "README.md" and not p.startswith(("01 - Daily Notes/", "Archive/"))]
    uningested = [r for r in raws if r.lower() not in referenced_raw and not r.startswith("raw/assets/")]

    def section(title, items, fmt=str):
        print(f"\n## {title}: {len(items)}")
        for i in items:
            print("  - " + fmt(i))

    print(f"# wiki lint: {VAULT}")
    print(f"pages: {len(pages)}   raw files: {len(raws)}")
    section("Broken links", broken, lambda b: f"{b[0]}  ->  {b[1]}")
    section("Orphans (no inbound links)", orphans)
    section("Not listed in index.md", not_indexed)
    section("Raw sources not cited by any page", uningested)
    total = len(broken) + len(orphans) + len(not_indexed) + len(uningested)
    print(f"\nsummary: broken={len(broken)} orphans={len(orphans)} not_indexed={len(not_indexed)} "
          f"uningested_raw={len(uningested)} total={total}")


if __name__ == "__main__":
    main()
