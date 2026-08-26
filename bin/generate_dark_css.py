# Erzeugt den Ueberlagerungsteil von dark.css aus den Quell-Stylesheets.
#
# Von Hand aufgezaehlt hatte ich 77 Regeln uebersehen, und schlimmer: ein
# generisches "html[data-theme=dark] a" (0,1,2) verliert gegen "a.subheading:link"
# (0,2,1) aus oddb.css. Wer den Selektor der Quelle uebernimmt und nur
# html[data-theme="dark"] davorsetzt, ist immer spezifischer als das Original und
# steht ausserdem spaeter im Kopf - damit gewinnt er zweifach.
import re, sys, io, collections

FG = {
    "blue": "var(--dark-link)", "#0000ff": "var(--dark-link)", "#00f": "var(--dark-link)",
    "black": "var(--dark-text)", "#000": "var(--dark-text)", "#000000": "var(--dark-text)",
    "red": "var(--dark-red)", "#ff0000": "var(--dark-red)", "#f00": "var(--dark-red)",
    "#c00": "var(--dark-red)",
    "silver": "var(--dark-text-dim)", "gray": "var(--dark-text-dim)", "grey": "var(--dark-text-dim)",
    "#2ba476": "var(--dark-accent)", "#2ba576": "var(--dark-accent)",
    "green": "#7ddba0", "#080": "#7ddba0", "#0a0": "#7ddba0",
    "#b00": "var(--dark-red)",
    "#ff6600": "#ffab5e",
    "#a52a2a": "#e08c8c",
    "#f5e84d": "#f5e84d",   # schon hell genug
    "white": "#eaf3ee",
}
BG = {
    "#ccff99": "var(--dark-accent-bg)", "#ccff9a": "var(--dark-accent-bg)",
    "#dbffc3": "var(--dark-accent-bg-2)", "#ecffe6": "var(--dark-surface)",
    "#e9f7f3": "var(--dark-surface)", "#ddffdd": "var(--dark-surface)",
    "#dfd": "#1d3a26", "#fee": "#3a2028", "#fcc": "#5a2630", "#9f9": "#245c38",
    "white": "var(--dark-surface)", "#fff": "var(--dark-surface)", "#ffffff": "var(--dark-surface)",
    "#2ba476": "#17503c", "#2ba576": "#17503c",
    "#ccc": "var(--dark-surface-2)", "#cccccc": "var(--dark-surface-2)",
    "gray": "var(--dark-surface-2)", "grey": "var(--dark-surface-2)",
    "#7bcf88": "#2c6b45",
    "#184fca": "#2f5fb8",
    "#c00": "#8a1f1f", "#ff0000": "#8a1f1f",
    "transparent": "transparent", "none": "none",
}
# Diese Flaechen tragen Bedeutung durch ihre Farbe (Abzeichen, Warnstufen).
# Sie bleiben, wie sie sind - nur die Schrift darauf muss dunkel sein.
KEEP_BG = {"#fff88f", "#fff455", "#ffbc6f", "#ffbc22", "#ffc455", "#cf9", "#afa", "#faa",
           "#fbb", "#fdb", "#ffb", "#bfb", "#c8e696", "yellow", "#ff00ff", "#f61",
           "#dd1cff", "#9900ff", "#60f", "#0a0", "#a52a2a"}

def parse(path):
    s = io.open(path, encoding="utf-8", errors="replace").read()
    s = re.sub(r'/\*.*?\*/', '', s, flags=re.S)
    for sel, body in re.findall(r'([^{}]+)\{([^}]*)\}', s):
        sel = " ".join(sel.split())
        if not sel or sel.startswith("@") or "{" in sel:
            continue
        props = {}
        for decl in body.split(";"):
            m = re.match(r'\s*(background-color|background|color)\s*:\s*([^;!]+)', decl)
            if m:
                props[m.group(1)] = m.group(2).strip().lower()
        if props:
            yield sel, props

out, seen = [], set()
for path in sys.argv[1:]:
    for sel, props in parse(path):
        decls = []
        # Bleibt der helle Grund stehen, muss die Schrift dunkel sein - egal was
        # die Quelle sagt. Sonst entsteht hell auf hell: a.feedback ist schwarz
        # auf #ffbc6f, und ein aufgehelltes Schwarz waere darauf unlesbar.
        keeps_light_bg = any(
            prop != "color" and value in KEEP_BG for prop, value in props.items())
        if keeps_light_bg:
            decls.append("color: #14171a")
        else:
            for prop, value in props.items():
                if prop == "color":
                    new = FG.get(value)
                    if new: decls.append(f"color: {new}")
                else:
                    new = BG.get(value)
                    if new: decls.append(f"{prop}: {new}")
        if not decls: continue
        dark = ", ".join(f'html[data-theme="dark"] {p.strip()}' for p in sel.split(","))
        key = (dark, tuple(sorted(decls)))
        if key in seen: continue
        seen.add(key)
        out.append(f"{dark} {{\n  " + ";\n  ".join(decls) + ";\n}")

print("\n".join(out))
print(f"\n/* {len(out)} Regeln erzeugt */", file=sys.stderr)
