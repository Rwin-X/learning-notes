---
title: "Grid Weights and Window Resizing"
domain: "02-geometry-managers"
tags: [layout, grid, resizing]
created: 2026-07-27
type: atomic-note
---

# Grid Weights and Window Resizing

#layout #grid #resizing

By default, `grid()` cells don't grow when the window resizes — they stay their content size, and extra space collects as dead space. `columnconfigure`/`rowconfigure` with `weight` fixes this.

```python
root.columnconfigure(0, weight=1)   # column 0 absorbs extra horizontal space
root.columnconfigure(1, weight=3)   # column 1 absorbs 3x as much as column 0
root.rowconfigure(0, weight=1)

tk.Entry(root).grid(row=0, column=1, sticky="ew")  # sticky="ew" so it actually stretches
```

Mental model: `weight` is a **ratio**, not a pixel value. `weight=1` vs `weight=1` splits space 50/50; `weight=1` vs `weight=3` splits 25/75. Weight `0` (the default) means "never grow."

Common bug: setting `weight` but forgetting `sticky="nsew"` on the widget — the cell grows but the widget stays pinned in a corner of it.

See also: [[grid-geometry-manager]], [[frame-widget]]

---
📍 Part of [[02 Geometry Managers MOC|Geometry Managers MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
