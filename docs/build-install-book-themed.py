"""Build docs/EVIE-Install-Book.pdf: the published, themed (dark battle-station) edition.

    uv run --no-project --with markdown --with pymupdf python docs/build-install-book-themed.py

Same words as build-install-book.py: the chapters, the memory chapter and the markdown
handling are imported from it, so the two editions can never drift apart. Only the look differs.

How it works
  1. Chrome prints the text (light on transparent) to a PDF, with a full-bleed cover.
  2. Chrome prints one background page and a few ornaments (inline SVG) to small PDFs.
  3. PyMuPDF puts the background under every page, adds the running header/footer, and
     drops an ornament into any page that ends with a large blank area.
"""
import datetime, html, importlib.util, math, os, random, shutil, subprocess, sys, tempfile
import pymupdf

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
spec = importlib.util.spec_from_file_location("base", os.path.join(HERE, "build-install-book.py"))
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)

AUTHOR = "Jay Ortiz"
BRAND = "DARKSIDE STUDIO \u00b7 DROID STARTER KIT"
BOOK = "EVIE Install Book"
VARIANT = os.environ.get("BOOK_VARIANT", "2")          # 2 = hull-wall cover, big cropped stations (the published look); 1 = whole station on the cover
OUT_PDF = os.path.join(ROOT, "docs", os.environ.get("BOOK_OUT", "EVIE-Install-Book.pdf" if VARIANT == "2" else f"EVIE-Install-Book-v{VARIANT}.pdf"))
PT = float(os.environ.get("BOOK_PT", "10.5"))          # body size: tune to hold the page count
FONTS = r"C:\Windows\Fonts"

INK, STEEL, LINE, TEXT, WHITE = "#06080c", "#10151d", "#2a3442", "#c6ced8", "#f3f6f9"
RED, GREEN = "#e5383b", "#7dffa0"

CSS = f"""
@page {{ size: A4; margin: 23mm 17mm 23mm 17mm; }}
@page cover {{ size: A4; margin: 0; }}
* {{ box-sizing: border-box; -webkit-print-color-adjust: exact; print-color-adjust: exact; }}
html, body {{ margin: 0; background: transparent; }}
body {{ font-family: "Bahnschrift", "Segoe UI", sans-serif; font-weight: 300; font-size: {PT}pt;
       line-height: 1.5; color: {TEXT}; counter-reset: ch; }}
b, strong {{ color: {WHITE}; font-weight: 600; }}
a {{ color: #ff8f88; text-decoration: none; }}
h1 {{ font-family: "Agency FB", "Bahnschrift", sans-serif; font-weight: 700; font-size: 31pt; line-height: 1.05;
     color: {WHITE}; text-transform: uppercase; letter-spacing: 1.5px; margin: 0 0 16px; padding: 0 0 10px;
     page-break-before: always; counter-increment: ch; position: relative;
     border-bottom: 1.6pt solid; border-image: linear-gradient(90deg, {RED} 0, {RED} 34%, {LINE} 34%, rgba(42,52,66,0) 100%) 1; }}
h1::before {{ content: counter(ch, decimal-leading-zero); display: block; font-size: 15pt; letter-spacing: 4px;
     color: {RED}; margin-bottom: 2px; }}
h1.first {{ page-break-before: avoid; counter-increment: none; }}
h1.first::before {{ content: none; }}
h2 {{ font-family: "Agency FB", "Bahnschrift", sans-serif; font-weight: 700; font-size: 17.5pt; letter-spacing: .8px;
     color: {WHITE}; margin: 20px 0 6px; page-break-after: avoid; padding-left: 11px; border-left: 3.2pt solid {RED}; line-height: 1.15; }}
h3 {{ font-family: "Bahnschrift", sans-serif; font-weight: 600; font-size: {PT + 1}pt; color: #ff8f88;
     letter-spacing: .4px; margin: 14px 0 4px; page-break-after: avoid; }}
p {{ margin: 0 0 8px; }}
ul, ol {{ margin: 0 0 8px; padding-left: 20px; }}
li {{ margin: 2px 0; }}
li::marker {{ color: {RED}; }}
p, li {{ orphans: 3; widows: 3; }}
hr {{ border: 0; border-top: 1px solid {LINE}; margin: 14px 0; }}
code {{ font-family: Consolas, monospace; font-size: {PT - 1.1}pt; color: {GREEN}; background: #111922;
       border: .5pt solid #1f2a36; padding: 0 4px; border-radius: 2px; }}
pre {{ background: #0b1017; border: .6pt solid {LINE}; border-left: 3pt solid {GREEN}; color: #dfe7ef;
      padding: 9px 12px; border-radius: 0 4px 4px 0; white-space: pre-wrap; word-break: break-all;
      page-break-inside: avoid; margin: 8px 0 10px; }}
pre code {{ background: none; border: 0; color: inherit; padding: 0; font-size: {PT - 1.3}pt; }}
table {{ border-collapse: collapse; width: 100%; margin: 9px 0 12px; font-size: {PT - 1.1}pt; page-break-inside: auto; }}
tr {{ page-break-inside: avoid; }}
th {{ font-family: "Agency FB", sans-serif; font-weight: 700; font-size: {PT + 0.8}pt; letter-spacing: 1.4px; text-transform: uppercase;
     background: #18202b; color: {WHITE}; text-align: left; padding: 5px 8px; border-bottom: 1.4pt solid {RED}; }}
th code {{ text-transform: none; }}
td {{ border-bottom: .6pt solid #1e2732; padding: 5px 8px; vertical-align: top; }}
tr:nth-child(even) td {{ background: rgba(255,255,255,.028); }}
blockquote {{ border: .6pt solid #4a2226; border-left: 3pt solid {RED}; background: rgba(229,56,59,.07);
             margin: 10px 0; padding: 7px 12px 1px; border-radius: 0 4px 4px 0; }}

.toc {{ page-break-before: always; }}
.toc ol {{ list-style: none; padding: 0; margin: 18px 0 0; counter-reset: toc; }}
.toc li {{ counter-increment: toc; font-family: "Agency FB", sans-serif; font-weight: 700; font-size: 19pt; letter-spacing: 1px;
          color: {WHITE}; margin: 0; padding: 11px 0 11px 2px; border-bottom: .6pt solid {LINE}; display: flex; align-items: baseline; }}
.toc li::before {{ content: counter(toc, decimal-leading-zero); color: {RED}; width: 46px; letter-spacing: 3px; font-size: 15pt; }}

.cover {{ position: relative; width: 210mm; height: 296.8mm; overflow: hidden; background: {INK}; }}
.cover svg {{ position: absolute; left: 0; top: 0; width: 210mm; height: 297mm; }}
.cover .brand {{ position: absolute; left: 18mm; top: 19mm; font-family: "Agency FB", sans-serif; font-weight: 700;
                font-size: 12.5pt; letter-spacing: 5px; color: {RED}; }}
.cover .title {{ position: absolute; left: 17mm; top: 30mm; font-family: "Agency FB", sans-serif; font-weight: 700;
                font-size: 92pt; line-height: .9; letter-spacing: 2px; color: {WHITE}; text-transform: uppercase; }}
.cover .title span {{ display: block; }}
.cover .title .t2 {{ font-size: 56pt; letter-spacing: 9px; color: #aeb8c4; margin-top: 3mm; }}
.cover .sub {{ position: absolute; left: 18mm; top: 96mm; width: 120mm; font-size: 11.5pt; font-weight: 400; color: #aeb8c4; letter-spacing: .4px;
              padding-top: 4mm; border-top: 1.6pt solid {RED}; }}
.cover .author {{ position: absolute; left: 18mm; top: 114mm; font-family: "Agency FB", sans-serif; font-weight: 700; }}
.cover .author small {{ display: block; font-size: 10pt; letter-spacing: 5px; color: {RED}; }}
.cover .author b {{ font-size: 25pt; letter-spacing: 3px; color: {WHITE}; text-transform: uppercase; font-weight: 700; }}
.cover .oneline {{ position: absolute; left: 18mm; right: 18mm; bottom: 27mm; padding: 5mm 6mm 3mm;
                  background: rgba(6,8,12,.86); border: .6pt solid #3a4656; border-left: 3pt solid {GREEN}; font-size: 10.6pt; }}
.cover .oneline p {{ margin: 0 0 6px; }}
.cover .oneline pre {{ border-left: .6pt solid {LINE}; border-radius: 3px; background: #05080c; color: {GREEN}; }}
.cover .meta {{ position: absolute; left: 18mm; bottom: 14mm; font-family: "Agency FB", sans-serif; font-weight: 700; font-size: 11pt;
               letter-spacing: 4px; color: #8893a0; text-transform: uppercase; }}
"""


# ---------------------------------------------------------------- SVG art
def station(cx, cy, r, seed=7, uid="s"):
    """An armoured battle-station moon: plated sphere, equatorial trench, focusing dish."""
    rnd = random.Random(seed)
    o = [f'<defs><clipPath id="{uid}c"><circle cx="{cx}" cy="{cy}" r="{r}"/></clipPath>'
         f'<radialGradient id="{uid}g" cx="34%" cy="28%" r="80%"><stop offset="0" stop-color="#a9b4c1"/>'
         f'<stop offset=".45" stop-color="#5d6877"/><stop offset="1" stop-color="#1b212b"/></radialGradient>'
         f'<radialGradient id="{uid}sh" cx="30%" cy="24%" r="92%"><stop offset=".35" stop-color="#000" stop-opacity="0"/>'
         f'<stop offset=".8" stop-color="#000" stop-opacity=".72"/><stop offset="1" stop-color="#000" stop-opacity=".96"/></radialGradient>'
         f'<radialGradient id="{uid}d" cx="42%" cy="40%" r="62%"><stop offset="0" stop-color="#0c1016"/>'
         f'<stop offset=".7" stop-color="#3a4452"/><stop offset="1" stop-color="#aab5c2"/></radialGradient>'
         f'<radialGradient id="{uid}halo" cx="50%" cy="50%" r="50%"><stop offset=".8" stop-color="{RED}" stop-opacity="0"/>'
         f'<stop offset=".9" stop-color="{RED}" stop-opacity=".16"/><stop offset="1" stop-color="{RED}" stop-opacity="0"/></radialGradient></defs>']
    o.append(f'<circle cx="{cx}" cy="{cy}" r="{r*1.13:.1f}" fill="url(#{uid}halo)"/>')
    o.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#{uid}g)"/><g clip-path="url(#{uid}c)">')
    band = r / 17
    y = cy - r
    while y < cy + r:
        h = band * rnd.choice([.6, .8, 1, 1, 1.3])
        half = math.sqrt(max(r * r - min(abs(y - cy), abs(y + h - cy)) ** 2, 0))
        x = cx - half
        while x < cx + half:
            w = band * rnd.uniform(.7, 4.5)
            a = rnd.uniform(0, .17)
            col = "#fff" if rnd.random() < .42 else "#000"
            o.append(f'<rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" fill="{col}" fill-opacity="{a:.3f}"/>')
            x += w + band * .06
        o.append(f'<line x1="{cx-r}" x2="{cx+r}" y1="{y:.2f}" y2="{y:.2f}" stroke="#000" stroke-opacity=".28" stroke-width="{r*.0035:.3f}"/>')
        y += h
    # equatorial trench
    o.append(f'<rect x="{cx-r}" y="{cy - r*.012:.2f}" width="{2*r}" height="{r*.03:.2f}" fill="#05070a" fill-opacity=".9"/>')
    o.append(f'<line x1="{cx-r}" x2="{cx+r}" y1="{cy + r*.022:.2f}" y2="{cy + r*.022:.2f}" stroke="#cfd8e2" stroke-opacity=".28" stroke-width="{r*.004:.3f}"/>')
    # focusing dish
    dx, dy, drx, dry = cx - r * .43, cy - r * .43, r * .27, r * .235
    o.append(f'<g transform="rotate(-38 {dx:.2f} {dy:.2f})"><ellipse cx="{dx:.2f}" cy="{dy:.2f}" rx="{drx:.2f}" ry="{dry:.2f}" fill="url(#{uid}d)" stroke="#d5dde6" stroke-opacity=".5" stroke-width="{r*.005:.3f}"/>')
    for k in (.72, .46, .22):
        o.append(f'<ellipse cx="{dx:.2f}" cy="{dy:.2f}" rx="{drx*k:.2f}" ry="{dry*k:.2f}" fill="none" stroke="#000" stroke-opacity=".5" stroke-width="{r*.004:.3f}"/>')
    o.append('</g>')
    o.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#{uid}sh)"/></g>')
    o.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="#dfe6ee" stroke-opacity=".22" stroke-width="{r*.004:.3f}"/>')
    return "".join(o), (dx, dy, drx)


def beam(dx, dy, drx, ex, ey, s=1.0):
    """Converging rays over the dish, then one beam out to (ex, ey)."""
    ux, uy = ex - dx, ey - dy
    n = math.hypot(ux, uy); ux, uy = ux / n, uy / n
    fx, fy = dx + ux * drx * .5, dy + uy * drx * .5
    o = []
    for k in range(8):
        a = k * math.pi / 4 + .2
        px, py = dx + math.cos(a) * drx * .86, dy + math.sin(a) * drx * .8
        o.append(f'<line x1="{px:.2f}" y1="{py:.2f}" x2="{fx:.2f}" y2="{fy:.2f}" stroke="{GREEN}" stroke-opacity=".75" stroke-width="{.35*s}"/>')
    for w, a in ((9, .05), (5.5, .09), (3, .2), (1.5, .5), (.6, 1)):
        o.append(f'<line x1="{fx:.2f}" y1="{fy:.2f}" x2="{ex}" y2="{ey}" stroke="{"#eafff0" if w < 1 else GREEN}" stroke-opacity="{a}" stroke-width="{w*s}" stroke-linecap="round"/>')
    for rr, a in ((7, .08), (4, .2), (2, .6), (1, 1)):
        o.append(f'<circle cx="{fx:.2f}" cy="{fy:.2f}" r="{rr*s}" fill="{"#fff" if rr == 1 else GREEN}" fill-opacity="{a}"/>')
    return "".join(o)


def stars(w, h, n, seed=3):
    rnd = random.Random(seed)
    return "".join(f'<circle cx="{rnd.uniform(0,w):.1f}" cy="{rnd.uniform(0,h):.1f}" r="{rnd.choice([.12,.16,.2,.2,.3,.45]):.2f}" '
                   f'fill="#fff" fill-opacity="{rnd.uniform(.25,.95):.2f}"/>' for _ in range(n))


def brackets(x0, y0, x1, y1, L, col=RED, sw=.5):
    p = []
    for (x, y, sx, sy) in ((x0, y0, 1, 1), (x1, y0, -1, 1), (x0, y1, 1, -1), (x1, y1, -1, -1)):
        p.append(f'<path d="M{x+sx*L} {y} H{x} V{y+sy*L}" fill="none" stroke="{col}" stroke-width="{sw}"/>')
    return "".join(p)


def cover_svg():
    body, (dx, dy, drx) = station(140, 224, 106, seed=11, uid="cv")
    grid = "".join(f'<line x1="{x}" y1="0" x2="{x}" y2="297" stroke="#fff" stroke-opacity=".022" stroke-width=".2"/>' for x in range(0, 211, 10)) + \
           "".join(f'<line x1="0" y1="{y}" x2="210" y2="{y}" stroke="#fff" stroke-opacity=".022" stroke-width=".2"/>' for y in range(0, 298, 10))
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 210 297"><defs>'
            f'<radialGradient id="bg" cx="70%" cy="72%" r="95%"><stop offset="0" stop-color="#1a2230"/><stop offset=".5" stop-color="#0b0f16"/><stop offset="1" stop-color="#040508"/></radialGradient>'
            f'<linearGradient id="fade" x1="0" y1="0" x2="0" y2="1"><stop offset=".55" stop-color="{INK}" stop-opacity="0"/><stop offset="1" stop-color="{INK}" stop-opacity=".9"/></linearGradient></defs>'
            f'<rect width="210" height="297" fill="url(#bg)"/>{grid}{stars(210, 297, 330)}{body}'
            f'{beam(dx, dy, drx, -12, 150)}'
            f'<rect width="210" height="297" fill="url(#fade)"/>'
            f'{brackets(9, 9, 201, 288, 9)}'
            f'<line x1="9" y1="24" x2="9" y2="273" stroke="#fff" stroke-opacity=".12" stroke-width=".25"/>'
            f'<line x1="201" y1="24" x2="201" y2="273" stroke="#fff" stroke-opacity=".12" stroke-width=".25"/></svg>')


def background_svg():
    ticks = "".join(f'<line x1="6.5" x2="{8.5 if i % 5 else 10}" y1="{30 + i*4}" y2="{30 + i*4}" stroke="#fff" stroke-opacity=".16" stroke-width=".2"/>' for i in range(60))
    ticks += "".join(f'<line x1="203.5" x2="{201.5 if i % 5 else 200}" y1="{30 + i*4}" y2="{30 + i*4}" stroke="#fff" stroke-opacity=".16" stroke-width=".2"/>' for i in range(60))
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 210 297"><defs>'
            f'<radialGradient id="bg" cx="50%" cy="38%" r="85%"><stop offset="0" stop-color="#10151e"/><stop offset=".6" stop-color="#0a0d13"/><stop offset="1" stop-color="#05070a"/></radialGradient>'
            f'<linearGradient id="hl" x1="0" x2="1"><stop offset="0" stop-color="{RED}"/><stop offset=".18" stop-color="{RED}"/><stop offset=".18" stop-color="#3a4656"/><stop offset="1" stop-color="#3a4656" stop-opacity=".25"/></linearGradient></defs>'
            f'<rect width="210" height="297" fill="url(#bg)"/>{stars(210, 297, 45, seed=21)}'
            f'<rect width="210" height="297" fill="#06080c" fill-opacity=".72"/>'
            f'<circle cx="222" cy="318" r="92" fill="none" stroke="#fff" stroke-opacity=".05" stroke-width=".3"/>'
            f'<circle cx="222" cy="318" r="80" fill="none" stroke="#fff" stroke-opacity=".04" stroke-width=".3" stroke-dasharray="1.5 2"/>'
            f'<rect x="17" y="16" width="176" height=".45" fill="url(#hl)"/>'
            f'<path d="M17 281.3 H86 l3 -2.4 H121 l3 2.4 H193" fill="none" stroke="#3a4656" stroke-width=".35"/>'
            f'{brackets(6.5, 6.5, 203.5, 290.5, 6, sw=.45)}{ticks}</svg>')


def orn_wide_a():           # trench run, 178 x 52
    vx, vy = 89, 15
    o = []
    for i in range(-9, 10):
        o.append(f'<line x1="{vx}" y1="{vy}" x2="{89 + i*16}" y2="52" stroke="#5b6878" stroke-opacity="{.5 - abs(i)*.035:.2f}" stroke-width=".25"/>')
    y, step = vy + 1.2, 1.1
    while y < 52:
        t = (y - vy) / 37
        o.append(f'<line x1="{89 - 150*t:.1f}" x2="{89 + 150*t:.1f}" y1="{y:.2f}" y2="{y:.2f}" stroke="#5b6878" stroke-opacity="{.12 + .4*t:.2f}" stroke-width=".25"/>')
        y += step; step *= 1.32
    o.append(f'<line x1="0" x2="178" y1="{vy}" y2="{vy}" stroke="#3a4656" stroke-width=".3"/>')
    o.append(brackets(vx - 7, vy - 7, vx + 7, vy + 7, 3, sw=.45))
    o.append(f'<circle cx="{vx}" cy="{vy}" r="1" fill="{GREEN}"/><circle cx="{vx}" cy="{vy}" r="3" fill="{GREEN}" fill-opacity=".18"/>')
    o.append(f'<line x1="{vx-22}" x2="{vx-9}" y1="{vy}" y2="{vy}" stroke="{RED}" stroke-width=".4"/><line x1="{vx+9}" x2="{vx+22}" y1="{vy}" y2="{vy}" stroke="{RED}" stroke-width=".4"/>')
    return 178, 52, "".join(o)


def wire_station(cx, cy, r, sw=.3):
    o = [f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#0c1118" stroke="#8792a0" stroke-width="{sw*1.4}"/>']
    for k in (.92, .72, .45, .16):
        o.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{r*k:.2f}" ry="{r}" fill="none" stroke="#5b6878" stroke-opacity=".55" stroke-width="{sw*.7}"/>')
    for k in (-.8, -.55, -.28, .28, .55, .8):
        half = r * math.sqrt(1 - k * k)
        o.append(f'<line x1="{cx-half:.2f}" x2="{cx+half:.2f}" y1="{cy + r*k:.2f}" y2="{cy + r*k:.2f}" stroke="#5b6878" stroke-opacity=".55" stroke-width="{sw*.7}"/>')
    o.append(f'<line x1="{cx-r}" x2="{cx+r}" y1="{cy - r*.02:.2f}" y2="{cy - r*.02:.2f}" stroke="#c6ced8" stroke-width="{sw}"/>'
             f'<line x1="{cx-r}" x2="{cx+r}" y1="{cy + r*.02:.2f}" y2="{cy + r*.02:.2f}" stroke="#c6ced8" stroke-width="{sw}"/>')
    dx, dy = cx - r * .42, cy - r * .42
    o.append(f'<g transform="rotate(-38 {dx:.2f} {dy:.2f})"><ellipse cx="{dx:.2f}" cy="{dy:.2f}" rx="{r*.26:.2f}" ry="{r*.22:.2f}" fill="#070a0f" stroke="#c6ced8" stroke-width="{sw}"/>'
             f'<ellipse cx="{dx:.2f}" cy="{dy:.2f}" rx="{r*.15:.2f}" ry="{r*.125:.2f}" fill="none" stroke="#5b6878" stroke-width="{sw*.7}"/></g>'
             f'<circle cx="{dx:.2f}" cy="{dy:.2f}" r="{r*.035:.2f}" fill="{GREEN}"/><circle cx="{dx:.2f}" cy="{dy:.2f}" r="{r*.1:.2f}" fill="{GREEN}" fill-opacity=".2"/>')
    return "".join(o)


def orn_wide_b():           # scan line with a small station, 178 x 52
    o = ['<defs><linearGradient id="l" x1="0" x2="1"><stop offset="0" stop-color="#5b6878" stop-opacity="0"/><stop offset=".5" stop-color="#5b6878"/><stop offset="1" stop-color="#5b6878" stop-opacity="0"/></linearGradient></defs>']
    for dy, w in ((-9, 150), (0, 178), (9, 150)):
        o.append(f'<rect x="{89 - w/2}" y="{26 + dy - .12}" width="{w}" height=".24" fill="url(#l)"/>')
    for i in range(-20, 21):
        if abs(i) < 6: continue
        o.append(f'<line x1="{89 + i*4}" x2="{89 + i*4}" y1="{26 - (1.6 if i % 5 else 3)}" y2="{26 + (1.6 if i % 5 else 3)}" stroke="#8792a0" stroke-opacity="{.75 - abs(i)*.03:.2f}" stroke-width=".25"/>')
    o.append(f'<circle cx="89" cy="26" r="21.5" fill="none" stroke="{RED}" stroke-width=".3" stroke-dasharray="6 3 1 3"/>')
    o.append(wire_station(89, 26, 17))
    o.append(f'<rect x="38" y="25" width="2" height="2" fill="{RED}"/><rect x="138" y="25" width="2" height="2" fill="{RED}"/>')
    return 178, 52, "".join(o)


def orn_tall_a():           # targeting schematic, 178 x 130
    cx, cy, r = 89, 65, 40
    o = []
    for rr, dash, col, a in ((49, "1 2.2", "#8792a0", .7), (57, "", "#3a4656", 1), (63, "14 5 2 5", RED, .85)):
        o.append(f'<circle cx="{cx}" cy="{cy}" r="{rr}" fill="none" stroke="{col}" stroke-opacity="{a}" stroke-width=".3" {"stroke-dasharray=" + chr(34) + dash + chr(34) if dash else ""}/>')
    for d in range(0, 360, 5):
        a = math.radians(d); L = 3 if d % 15 == 0 else 1.4
        o.append(f'<line x1="{cx + 57*math.cos(a):.2f}" y1="{cy + 57*math.sin(a):.2f}" x2="{cx + (57-L)*math.cos(a):.2f}" y2="{cy + (57-L)*math.sin(a):.2f}" stroke="#8792a0" stroke-opacity=".7" stroke-width=".25"/>')
    o.append(f'<line x1="0" x2="{cx-66}" y1="{cy}" y2="{cy}" stroke="#3a4656" stroke-width=".3"/><line x1="{cx+66}" x2="178" y1="{cy}" y2="{cy}" stroke="#3a4656" stroke-width=".3"/>'
             f'<line x1="{cx}" x2="{cx}" y1="0" y2="{cy-66}" stroke="#3a4656" stroke-width=".3" stroke-dasharray="2 2"/><line x1="{cx}" x2="{cx}" y1="{cy+66}" y2="130" stroke="#3a4656" stroke-width=".3" stroke-dasharray="2 2"/>')
    for i in range(1, 9):
        o.append(f'<line x1="{i*3}" x2="{i*3}" y1="{cy-1.5}" y2="{cy+1.5}" stroke="#8792a0" stroke-opacity=".6" stroke-width=".25"/><line x1="{178-i*3}" x2="{178-i*3}" y1="{cy-1.5}" y2="{cy+1.5}" stroke="#8792a0" stroke-opacity=".6" stroke-width=".25"/>')
    o.append(wire_station(cx, cy, r, sw=.35))
    o.append(brackets(cx - 70, cy - 62, cx + 70, cy + 62, 7, sw=.5))
    return 178, 130, "".join(o)


def orn_tall_b():           # hull plating fading out around a station, 178 x 130
    cx, cy, R = 89, 65, 6.2
    rnd = random.Random(5)
    o = []
    hx, hy = R * 1.5, R * math.sqrt(3)
    for i in range(-12, 13):
        for j in range(-8, 9):
            x, y = cx + i * hx, cy + j * hy + (hy / 2 if i % 2 else 0)
            d = math.hypot((x - cx) / 86, (y - cy) / 62)
            if d > 1 or math.hypot(x - cx, y - cy) < 30: continue
            a = (1 - d) ** 1.3
            pts = " ".join(f"{x + R*.94*math.cos(math.radians(60*k)):.2f},{y + R*.94*math.sin(math.radians(60*k)):.2f}" for k in range(6))
            roll = rnd.random()
            fill = (RED, .22 * a) if roll < .05 else ("#8792a0", .12 * a) if roll < .28 else ("none", 0)
            o.append(f'<polygon points="{pts}" fill="{fill[0]}" fill-opacity="{fill[1]:.3f}" stroke="#6c7887" stroke-opacity="{.7*a:.2f}" stroke-width=".25"/>')
    o.append(f'<circle cx="{cx}" cy="{cy}" r="27" fill="none" stroke="{RED}" stroke-width=".3" stroke-dasharray="8 3 1 3"/>')
    o.append(wire_station(cx, cy, 22, sw=.32))
    return 178, 130, "".join(o)


# ---------------------------------------------------------------- variant 2: hull wall + big cropped stations
TONES = ["#5c6774", "#697481", "#76818e", "#838e9b", "#909ba7"]


def _box(x, y, w, h, fill, s=.55, rx=0):
    if w <= 0 or h <= 0: return ""
    o = f'<rect x="{x+s:.2f}" y="{y+s:.2f}" width="{w:.2f}" height="{h:.2f}" rx="{rx}" fill="#000" fill-opacity=".5"/>' if s else ""
    o += f'<rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" rx="{rx}" fill="{fill}"/>'
    if not rx:
        o += (f'<path d="M{x:.2f} {y+h:.2f}V{y:.2f}H{x+w:.2f}" fill="none" stroke="#fff" stroke-opacity=".5" stroke-width=".22"/>'
              f'<path d="M{x+w:.2f} {y:.2f}V{y+h:.2f}H{x:.2f}" fill="none" stroke="#000" stroke-opacity=".55" stroke-width=".22"/>')
    return o


def _dome(cx, cy, r):
    return (f'<circle cx="{cx+r*.18:.2f}" cy="{cy+r*.18:.2f}" r="{r:.2f}" fill="#000" fill-opacity=".5"/>'
            f'<circle cx="{cx:.2f}" cy="{cy:.2f}" r="{r:.2f}" fill="url(#gdome)"/>')


def _pit(cx, cy, r):
    return (f'<circle cx="{cx:.2f}" cy="{cy:.2f}" r="{r:.2f}" fill="#05070a"/>'
            f'<path d="M{cx-r*.7:.2f} {cy+r*.7:.2f}A{r:.2f} {r:.2f} 0 0 0 {cx+r*.7:.2f} {cy-r*.7:.2f}" fill="none" stroke="#fff" stroke-opacity=".5" stroke-width=".25"/>')


def _hole(x, y, w, h):
    return (f'<rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" fill="#05070a"/>'
            f'<rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{min(h, 1.6):.2f}" fill="#000"/>'
            f'<path d="M{x+w:.2f} {y:.2f}V{y+h:.2f}H{x:.2f}" fill="none" stroke="#fff" stroke-opacity=".45" stroke-width=".25"/>')


def _module(rnd, x, y, w, h):
    t = lambda: rnd.choice(TONES)
    big = min(w, h)
    kinds = ["slats", "slats", "plates", "plates", "studs", "traces", "pipes", "pistons", "grille"]
    if big > 11: kinds += ["dome", "dome", "recess", "recess", "sockets", "sockets", "hexport"]
    k = rnd.choice(kinds)
    o = []
    if k == "slats":
        if rnd.random() < .6:
            n = max(2, int(h / 2.3)); st = h / n
            o += [_box(x, y + i * st, w, st * .62, t(), .4) for i in range(n)]
        else:
            n = max(2, int(w / 2.3)); st = w / n
            o += [_box(x + i * st, y, st * .62, h, t(), .4) for i in range(n)]
    elif k == "plates":
        for _ in range(rnd.randint(2, 5)):
            pw, ph = rnd.uniform(.3, .8) * w, rnd.uniform(.3, .8) * h
            o.append(_box(x + rnd.uniform(0, w - pw), y + rnd.uniform(0, h - ph), pw, ph, t()))
    elif k == "studs":
        o.append(_box(x, y, w, h, t(), .4))
        st = rnd.choice([2.6, 3.2]); r = st * .3
        for i in range(int((w - 1) / st)):
            for j in range(int((h - 1) / st)):
                o.append(_dome(x + 1 + st / 2 + i * st, y + 1 + st / 2 + j * st, r))
    elif k == "traces":
        for _ in range(rnd.randint(3, 6)):
            px, py = x + rnd.uniform(0, w), y + rnd.uniform(0, h)
            d = f"M{px:.2f} {py:.2f}"
            for q in range(rnd.randint(2, 4)):
                if q % 2: px = x + rnd.uniform(0, w); d += f"H{px:.2f}"
                else: py = y + rnd.uniform(0, h); d += f"V{py:.2f}"
            o.append(f'<path d="{d}" transform="translate(.4 .4)" fill="none" stroke="#000" stroke-opacity=".5" stroke-width="1.1" stroke-linejoin="round" stroke-linecap="round"/>'
                     f'<path d="{d}" fill="none" stroke="{t()}" stroke-width="1" stroke-linejoin="round" stroke-linecap="round"/>'
                     f'<path d="{d}" transform="translate(-.2 -.2)" fill="none" stroke="#fff" stroke-opacity=".4" stroke-width=".22" stroke-linejoin="round"/>')
            o.append(_dome(px, py, .9))
    elif k == "pipes":
        n = max(2, int(w / 4.2)); st = w / n
        for i in range(n):
            px = x + i * st + st * .15
            o.append(f'<rect x="{px+.5:.2f}" y="{y+.5:.2f}" width="{st*.7:.2f}" height="{h:.2f}" rx="{st*.3:.2f}" fill="#000" fill-opacity=".5"/>'
                     f'<rect x="{px:.2f}" y="{y:.2f}" width="{st*.7:.2f}" height="{h:.2f}" rx="{st*.3:.2f}" fill="url(#gcyl)"/>')
            yy = y + h * .3
            while yy < y + h * .7:
                o.append(f'<line x1="{px:.2f}" x2="{px+st*.7:.2f}" y1="{yy:.2f}" y2="{yy:.2f}" stroke="#000" stroke-opacity=".55" stroke-width=".25"/>'); yy += .7
    elif k == "pistons":
        n = max(2, int(w / 4.6)); st = w / n
        for i in range(n):
            px = x + i * st
            o += [_box(px + st * .3, y, st * .4, h, t(), .4), _box(px + st * .12, y + h * .08, st * .76, h * .2, t()),
                  _box(px + st * .2, y + h * .5, st * .6, h * .3, t()), _box(px + st * .08, y + h * .88, st * .3, h * .1, t(), .3),
                  _box(px + st * .62, y + h * .88, st * .3, h * .1, t(), .3)]
    elif k == "grille":
        o.append(_box(x, y, w, h, t()))
        o.append(_box(x + w * .12, y + h * .12, w * .76, h * .76, "#3b434e", 0))
        yy = y + h * .12 + .5
        while yy < y + h * .88 - .3:
            o.append(f'<line x1="{x+w*.12+.4:.2f}" x2="{x+w*.88-.4:.2f}" y1="{yy:.2f}" y2="{yy:.2f}" stroke="#0a0d11" stroke-width=".35"/>'); yy += .8
    elif k == "dome":
        o.append(_box(x + w * .08, y + h * .08, w * .84, h * .84, t()))
        r = big * .33
        o.append(f'<circle cx="{x+w/2:.2f}" cy="{y+h/2:.2f}" r="{r*1.15:.2f}" fill="none" stroke="#000" stroke-opacity=".45" stroke-width=".35"/>')
        o.append(_dome(x + w / 2, y + h / 2, r))
    elif k == "recess":
        o.append(_box(x, y, w, h, t()))
        o.append(_box(x + w * .1, y + h * .1, w * .8, h * .8, t(), .3))
        o.append(_hole(x + w * .2, y + h * .2, w * .6, h * .6))
        o.append(_box(x + w * .14, y + h * .62, w * .2, h * .2, t()))
    elif k == "sockets":
        o.append(_box(x, y + h * .1, w, h * .8, t()))
        n = 2 if w > h * 1.3 else 1
        r = min(w / n, h) * .3
        for i in range(n):
            cx = x + w * (i + .5) / n
            o.append(f'<circle cx="{cx:.2f}" cy="{y+h/2:.2f}" r="{r*1.18:.2f}" fill="{t()}" stroke="#fff" stroke-opacity=".35" stroke-width=".22"/>')
            o.append(_pit(cx, y + h / 2, r * .85))
    elif k == "hexport":
        cx, cy, r = x + w / 2, y + h / 2, big * .46
        pts = lambda rr, ox=0: " ".join(f"{cx+ox+rr*math.cos(math.radians(60*q+30)):.2f},{cy+ox+rr*math.sin(math.radians(60*q+30)):.2f}" for q in range(6))
        o.append(f'<polygon points="{pts(r, .7)}" fill="#000" fill-opacity=".5"/><polygon points="{pts(r)}" fill="{t()}" stroke="#fff" stroke-opacity=".4" stroke-width=".25"/>'
                 f'<polygon points="{pts(r*.78)}" fill="{t()}" stroke="#000" stroke-opacity=".5" stroke-width=".25"/>')
        o.append(_pit(cx, cy, r * .5))
        o.append(f'<circle cx="{cx:.2f}" cy="{cy:.2f}" r="{r*.5:.2f}" fill="none" stroke="#9aa5b2" stroke-width=".7" stroke-dasharray=".5 .5"/>')
    return "".join(o)


def hull_wall(w, h, seed=4):
    """Dense relief plating: a grid of machined modules lit from the upper left."""
    rnd = random.Random(seed)
    cells = []

    def split(x, y, cw, ch):
        long = max(cw, ch)
        if long > 34 or (long > 15 and rnd.random() < .7):
            f = rnd.uniform(.36, .64)
            if cw >= ch: split(x, y, cw * f, ch); split(x + cw * f, y, cw * (1 - f), ch)
            else: split(x, y, cw, ch * f); split(x, y + ch * f, cw, ch * (1 - f))
        else:
            cells.append((x, y, cw, ch))

    split(-3, -3, w + 6, h + 6)
    o = ['<defs><radialGradient id="gdome" cx="34%" cy="30%" r="75%"><stop offset="0" stop-color="#dfe5ec"/><stop offset=".5" stop-color="#8b96a3"/><stop offset="1" stop-color="#333b46"/></radialGradient>'
         '<linearGradient id="gcyl" x1="0" x2="1"><stop offset="0" stop-color="#4c5561"/><stop offset=".3" stop-color="#cfd6de"/><stop offset=".6" stop-color="#7b8693"/><stop offset="1" stop-color="#2a313a"/></linearGradient></defs>',
         f'<rect x="-3" y="-3" width="{w+6}" height="{h+6}" fill="#12161c"/>']
    lights = []
    for (x, y, cw, ch) in cells:
        o.append(_box(x + .3, y + .3, cw - .6, ch - .6, rnd.choice(TONES[:3]), 0))
        m = 1.3
        o.append(_module(rnd, x + m, y + m, cw - 2 * m, ch - 2 * m))
        if rnd.random() < .12:
            lights.append((x + cw - 2.2, y + 2.2))
    return "".join(o), lights


def cover_svg_v2():
    wall, lights = hull_wall(210, 297, seed=int(os.environ.get("BOOK_SEED", "4")))
    lit = ""
    for (x, y) in lights:
        if 120 < y < 262:
            lit += (f'<circle cx="{x:.1f}" cy="{y:.1f}" r="3.2" fill="{RED}" fill-opacity=".16"/><circle cx="{x:.1f}" cy="{y:.1f}" r="1.5" fill="{RED}" fill-opacity=".35"/>'
                    f'<circle cx="{x:.1f}" cy="{y:.1f}" r=".6" fill="#ffd9d6"/>')
    gx, gy = 150, 176      # the lit port
    hx = lambda rr: " ".join(f"{gx+rr*math.cos(math.radians(60*q+30)):.2f},{gy+rr*math.sin(math.radians(60*q+30)):.2f}" for q in range(6))
    port = (f'<polygon points="{hx(14.5)}" fill="#7a8593" stroke="#e8edf2" stroke-opacity=".6" stroke-width=".3"/><polygon points="{hx(11)}" fill="#5c6774" stroke="#000" stroke-opacity=".6" stroke-width=".3"/>'
            f'<circle cx="{gx}" cy="{gy}" r="7.4" fill="#04110a"/><circle cx="{gx}" cy="{gy}" r="7.4" fill="none" stroke="{GREEN}" stroke-width=".8" stroke-dasharray=".6 .6"/>'
            f'<circle cx="{gx}" cy="{gy}" r="3" fill="{GREEN}" fill-opacity=".85"/><circle cx="{gx}" cy="{gy}" r="1.3" fill="#fff"/>')
    port += "".join(f'<circle cx="{gx}" cy="{gy}" r="{r}" fill="{GREEN}" fill-opacity="{a}"/>' for r, a in ((34, .05), (22, .08), (13, .14), (7, .3)))
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 210 297"><defs>'
            f'<linearGradient id="dk" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{INK}" stop-opacity=".88"/><stop offset=".3" stop-color="{INK}" stop-opacity=".82"/>'
            f'<stop offset=".46" stop-color="{INK}" stop-opacity=".36"/><stop offset=".58" stop-color="{INK}" stop-opacity=".03"/><stop offset=".78" stop-color="{INK}" stop-opacity=".1"/><stop offset="1" stop-color="{INK}" stop-opacity=".8"/></linearGradient>'
            f'<linearGradient id="sd" x1="0" x2="1"><stop offset="0" stop-color="{INK}" stop-opacity=".55"/><stop offset=".3" stop-color="{INK}" stop-opacity="0"/><stop offset=".8" stop-color="{INK}" stop-opacity="0"/><stop offset="1" stop-color="{INK}" stop-opacity=".5"/></linearGradient>'
            f'<radialGradient id="tint" cx="72%" cy="60%" r="70%"><stop offset="0" stop-color="#2b4a6b" stop-opacity="0"/><stop offset="1" stop-color="#0b1626" stop-opacity=".3"/></radialGradient></defs>'
            f'{wall}{port}{lit}<rect width="210" height="297" fill="url(#tint)"/><rect width="210" height="297" fill="url(#dk)"/><rect width="210" height="297" fill="url(#sd)"/>'
            f'{brackets(9, 9, 201, 288, 9)}'
            f'<line x1="9" y1="24" x2="9" y2="273" stroke="#fff" stroke-opacity=".14" stroke-width=".25"/>'
            f'<line x1="201" y1="24" x2="201" y2="273" stroke="#fff" stroke-opacity=".14" stroke-width=".25"/></svg>')


def big_station(h, side="r", seed=2):
    """Region 210 x h mm: an oversized schematic station pushed off one edge and cropped."""
    rnd = random.Random(seed)
    r = h * .64
    cx, cy = 152, r + 14
    o = [f'<defs><clipPath id="bc"><circle cx="{cx}" cy="{cy}" r="{r}"/></clipPath></defs>']
    for rr, dash, col, a in ((r + 9, "1 2.4", "#8792a0", .7), (r + 17, "", "#3a4656", 1), (r + 24, "22 6 2 6", RED, .85)):
        da = f'stroke-dasharray="{dash}"' if dash else ""
        o.append(f'<circle cx="{cx}" cy="{cy}" r="{rr:.1f}" fill="none" stroke="{col}" stroke-opacity="{a}" stroke-width=".32" {da}/>')
    for d in range(0, 360, 2):
        a = math.radians(d); L = 3.4 if d % 10 == 0 else 1.5
        o.append(f'<line x1="{cx + (r+17)*math.cos(a):.2f}" y1="{cy + (r+17)*math.sin(a):.2f}" x2="{cx + (r+17-L)*math.cos(a):.2f}" y2="{cy + (r+17-L)*math.sin(a):.2f}" stroke="#8792a0" stroke-opacity=".7" stroke-width=".25"/>')
    o.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#0b1017" stroke="#aab4c0" stroke-width=".5"/><g clip-path="url(#bc)">')
    band = r / 15
    y = cy - r
    while y < cy + r:                                   # faint plating
        x = cx - r
        while x < cx + r:
            w = band * rnd.uniform(.8, 4)
            if rnd.random() < .3:
                col = RED if rnd.random() < .06 else "#8792a0"
                o.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{band:.1f}" fill="{col}" fill-opacity="{rnd.uniform(.04, .13):.2f}"/>')
            x += w
        y += band
    for k in (.97, .88, .74, .56, .36, .13):
        o.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{r*k:.2f}" ry="{r}" fill="none" stroke="#5b6878" stroke-opacity=".6" stroke-width=".25"/>')
    for i in range(-14, 15):
        k = i / 15
        if i == 0: continue
        half = r * math.sqrt(1 - k * k)
        o.append(f'<line x1="{cx-half:.2f}" x2="{cx+half:.2f}" y1="{cy + r*k:.2f}" y2="{cy + r*k:.2f}" stroke="#5b6878" stroke-opacity=".5" stroke-width=".22"/>')
    o.append(f'<rect x="{cx-r}" y="{cy - r*.014:.2f}" width="{2*r}" height="{r*.028:.2f}" fill="#04060a" stroke="#c6ced8" stroke-width=".35"/></g>')
    dx, dy, dr = cx - r * .43, cy - r * .45, r * .25
    o.append(f'<g transform="rotate(-38 {dx:.2f} {dy:.2f})"><ellipse cx="{dx:.2f}" cy="{dy:.2f}" rx="{dr:.2f}" ry="{dr*.86:.2f}" fill="#06090d" stroke="#d5dde6" stroke-width=".45"/>'
             + "".join(f'<ellipse cx="{dx:.2f}" cy="{dy:.2f}" rx="{dr*k:.2f}" ry="{dr*.86*k:.2f}" fill="none" stroke="#5b6878" stroke-width=".28"/>' for k in (.75, .5, .25)) + '</g>')
    o.append("".join(f'<circle cx="{dx:.2f}" cy="{dy:.2f}" r="{dr*k:.2f}" fill="{GREEN}" fill-opacity="{a}"/>' for k, a in ((.55, .07), (.3, .16), (.1, 1))))
    o.append(brackets(dx - dr * 1.3, dy - dr * 1.3, dx + dr * 1.3, dy + dr * 1.3, dr * .35, sw=.5))
    o.append(f'<line x1="0" x2="{dx - dr*1.3 - 3:.1f}" y1="{dy:.2f}" y2="{dy:.2f}" stroke="{RED}" stroke-opacity=".8" stroke-width=".3" stroke-dasharray="10 2 1 2"/>')
    for i in range(1, 12):
        o.append(f'<line x1="{17 + i*3}" x2="{17 + i*3}" y1="{dy-1.6:.2f}" y2="{dy+1.6:.2f}" stroke="#8792a0" stroke-opacity=".7" stroke-width=".25"/>')
    inner = "".join(o)
    if side == "l":
        inner = f'<g transform="translate(210 0) scale(-1 1)">{inner}</g>'
    return inner


# ---------------------------------------------------------------- build
def find_browser():
    b = next((p for p in [r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                          r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
                          shutil.which("chrome"), shutil.which("msedge")] if p and os.path.exists(p)), None)
    if not b:
        sys.exit("Chrome or Edge not found.")
    return b


def print_pdf(browser, tmp, name, doc):
    h, p = os.path.join(tmp, name + ".html"), os.path.join(tmp, name + ".pdf")
    with open(h, "w", encoding="utf-8") as f:
        f.write(doc)
    subprocess.run([browser, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                    f"--print-to-pdf={p}", "file:///" + h.replace("\\", "/")], check=True, timeout=180,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return p


def svg_page(w, h, inner, full=False):
    svg = inner if full else f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">{inner}</svg>'
    return (f"<!doctype html><html><head><meta charset='utf-8'><style>@page{{size:{w}mm {h}mm;margin:0}}"
            f"*{{-webkit-print-color-adjust:exact;print-color-adjust:exact}}html,body{{margin:0}}"
            f"svg{{display:block;width:{w}mm;height:{h - .2}mm}}</style></head><body>{svg}</body></html>")


def book_html():
    today = datetime.date.today().isoformat()
    cover = [f"""<div class="cover">{cover_svg_v2() if VARIANT == "2" else cover_svg()}
      <div class="brand">DARKSIDE STUDIO &middot; DROID STARTER KIT</div>
      <div class="title"><span>EVIE</span><span class="t2">Install Book</span></div>
      <div class="sub">Claude Code &middot; LLM-wiki memory &middot; Paid + offline gpt-oss &middot; voice</div>
      <div class="author"><small>WRITTEN BY</small><b>{html.escape(AUTHOR)}</b></div>
      <div class="oneline">
        <p><b>The whole install is one line</b> in Windows PowerShell:</p>
        <pre><code>irm https://raw.githubusercontent.com/DarkLordAlchemist/DarkSide_Studio-Droid-Starter-Kit/main/install.ps1 | iex</code></pre>
        <p>You need a Claude subscription for this first install. After that, the Local shortcuts run
        on gpt-oss-20b with no internet, no subscription, and no sign-in, ever.</p>
      </div>
      <div class="meta">Version 2 &middot; {today}</div>
    </div>"""]
    parts = []
    C = base.CHAPTERS
    toc = [C[0][0], "How EVIE's memory works"] + [c[0] for c in C[1:]]
    parts.append('<div class="toc"><h1 class="first">Contents</h1><ol>' + "".join(f"<li>{html.escape(t)}</li>" for t in toc) + "</ol></div>")
    read = lambda p: open(os.path.join(ROOT, p), encoding="utf-8").read()
    parts.append(base.chapter_html(C[0][0], read(C[0][1])))
    parts.append(base.chapter_html("How EVIE's memory works", base.MEMORY_CHAPTER))
    for title, path in C[1:]:
        parts.append(base.chapter_html(title, read(path)))
    wrap = lambda body, extra="": (f"<!doctype html><html><head><meta charset='utf-8'><title>{BOOK}</title>"
                                   f"<style>{CSS}{extra}</style></head><body>{body}</body></html>")
    return wrap("".join(parts)), wrap(cover[0], "@page { size: A4; margin: 0; }"), toc


def hexrgb(h):
    return tuple(int(h[i:i + 2], 16) / 255 for i in (1, 3, 5))


def spaced(page, font, x, y, text, size, color, track, align="l"):
    w = sum(font.text_length(c, fontsize=size) for c in text) + track * (len(text) - 1)
    if align == "r": x -= w
    if align == "c": x -= w / 2
    tw = pymupdf.TextWriter(page.rect)
    for c in text:
        tw.append((x, y), c, font=font, fontsize=size)
        x += font.text_length(c, fontsize=size) + track
    tw.write_text(page, color=hexrgb(color))


def main():
    browser = find_browser()
    tmp = tempfile.mkdtemp(prefix="eviebook_")
    doc_html, cover_html, titles = book_html()
    book = pymupdf.open(print_pdf(browser, tmp, "book", doc_html))
    book.insert_pdf(pymupdf.open(print_pdf(browser, tmp, "cover", cover_html)), from_page=0, to_page=0, start_at=0)
    bg = pymupdf.open(print_pdf(browser, tmp, "bg", svg_page(210, 297, background_svg(), full=True)))
    orn = {}
    for name, fn in (("wa", orn_wide_a), ("wb", orn_wide_b), ("ta", orn_tall_a), ("tb", orn_tall_b)):
        w, h, inner = fn()
        orn[name] = (pymupdf.open(print_pdf(browser, tmp, name, svg_page(w, h, inner))), w / h)

    MM = 72 / 25.4
    agency = pymupdf.Font(fontfile=os.path.join(FONTS, "AGENCYB.TTF"))
    chapter, n_wide, n_tall, placed = "", 0, 0, []
    for i, page in enumerate(book):
        if i == 0:
            continue
        page.wrap_contents()
        W, H = page.rect.width, page.rect.height
        # where does this page's real content end?
        bottom = 0
        for b in page.get_text("blocks"):
            if b[4].strip():
                bottom = max(bottom, b[3])
        for d in page.get_drawings():
            r = d["rect"]
            if r.height < H * .8 and r.y1 < H - 20 * MM:
                bottom = max(bottom, r.y1)
        big = " ".join(s["text"] for bl in page.get_text("dict")["blocks"] for l in bl.get("lines", [])
                       for s in l["spans"] if s["size"] > 24).upper()
        for t in titles + ["Contents"]:
            if t.upper() in " ".join(big.split()):
                chapter = t
        page.show_pdf_page(page.rect, bg, 0, overlay=False)
        gap = (H - 23 * MM) - bottom
        if gap > 42 * MM:
            if gap >= 105 * MM and VARIANT == "2" and i != 1:      # big cropped station (not on the contents page)
                top = bottom + 7 * MM
                hmm = round((H - 15.7 * MM - top) / MM, 1)
                side = "lr"[n_tall % 2]; n_tall += 1
                big = pymupdf.open(print_pdf(browser, tmp, f"big{i}", svg_page(210, hmm, big_station(hmm, side, seed=i))))
                page.show_pdf_page(pymupdf.Rect(0, top, W, top + hmm * MM), big, 0)
                placed.append((i + 1, "big-" + side, round(gap / MM)))
                key = None
            elif gap < 105 * MM:
                key = ("wa", "wb")[n_wide % 2]; n_wide += 1
            else:
                key = ("ta", "tb")[n_tall % 2]; n_tall += 1
            if key:
                src, ar = orn[key]
                top, bot = bottom + 9 * MM, H - 27 * MM
                h = min(bot - top, 176 * MM / ar, 150 * MM)
                w = h * ar
                y0 = top + (bot - top - h) / 2
                page.show_pdf_page(pymupdf.Rect((W - w) / 2, y0, (W + w) / 2, y0 + h), src, 0)
                placed.append((i + 1, key, round(gap / MM)))
        spaced(page, agency, 17 * MM, 13.2 * MM, BRAND, 7.5, "#8792a0", 2.2)
        spaced(page, agency, W - 17 * MM, 13.2 * MM, chapter.upper(), 7.5, RED, 2.2, "r")
        spaced(page, agency, 17 * MM, H - 10.6 * MM, BOOK.upper(), 7.5, "#8792a0", 2.2)
        spaced(page, agency, W - 17 * MM, H - 10.6 * MM, AUTHOR.upper(), 7.5, "#8792a0", 2.2, "r")
        spaced(page, agency, W / 2, H - 9.6 * MM, f"{i + 1:02d}", 11, WHITE, 1.5, "c")
    book.set_metadata({"title": BOOK, "author": AUTHOR, "subject": "DarkSide Studio Droid Starter Kit"})
    book.save(OUT_PDF, garbage=4, deflate=True)
    print("pages:", len(book), "| ornaments (page, kind, gap mm):", placed)
    print("wrote", OUT_PDF, os.path.getsize(OUT_PDF), "bytes")
    shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
