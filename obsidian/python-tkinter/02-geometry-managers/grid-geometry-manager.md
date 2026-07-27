---
title: "The Grid Geometry Manager"
domain: "02-geometry-managers"
tags: [layout, grid]
created: 2026-07-27
type: atomic-note
---

# The Grid Geometry Manager

#layout #grid

`.grid()` places widgets in a virtual row/column table within their parent. This is the recommended default for real applications.

```python
tk.Label(root, text="Username:").grid(row=0, column=0, sticky="e", padx=5, pady=5)
tk.Entry(root).grid(row=0, column=1, padx=5, pady=5)

tk.Label(root, text="Password:").grid(row=1, column=0, sticky="e", padx=5, pady=5)
tk.Entry(root, show="*").grid(row=1, column=1, padx=5, pady=5)

tk.Button(root, text="Login").grid(row=2, column=0, columnspan=2, pady=10)
```

Key options:
- `row`, `column`: 0-indexed grid position
- `sticky`: which edges the widget "sticks" to — combos of `n`, `s`, `e`, `w` (e.g. `"nsew"` fills the cell)
- `columnspan`/`rowspan`: merge cells
- `padx`/`pady`: spacing outside the widget

Use [[grid-weights-and-resizing]] to control how extra space is distributed when the window resizes — grid alone doesn't auto-stretch anything.

See also: [[geometry-manager-overview]], [[grid-weights-and-resizing]], [[building-a-form-layout]]

---
📍 Part of [[02 Geometry Managers MOC|Geometry Managers MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
