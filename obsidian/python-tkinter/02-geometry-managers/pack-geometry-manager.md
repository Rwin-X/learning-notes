---
title: "The Pack Geometry Manager"
domain: "02-geometry-managers"
tags: [layout, pack]
created: 2026-07-27
type: atomic-note
---

# The Pack Geometry Manager

#layout #pack

`.pack()` stacks widgets against a side of their parent, one after another, like books on a shelf.

```python
tk.Label(root, text="Top").pack(side="top")
tk.Label(root, text="Bottom").pack(side="bottom")
tk.Button(root, text="Fill me").pack(fill="x", expand=True, padx=10, pady=5)
```

Key options:
- `side`: `"top"` (default), `"bottom"`, `"left"`, `"right"`
- `fill`: `"x"`, `"y"`, or `"both"` — stretch the widget to fill available space
- `expand`: `True`/`False` — claim extra space when the window resizes
- `padx`/`pady`: outer spacing in pixels

Pack is fast for simple stacks but becomes unreadable for anything grid-like (forms, tables) — reach for [[grid-geometry-manager]] instead once you have more than ~3 widgets in a parent.

See also: [[geometry-manager-overview]], [[grid-geometry-manager]], [[mixing-geometry-managers-warning]]

---
📍 Part of [[02 Geometry Managers MOC|Geometry Managers MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
