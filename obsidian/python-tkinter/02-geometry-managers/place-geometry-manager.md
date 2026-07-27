---
title: "The Place Geometry Manager"
domain: "02-geometry-managers"
tags: [layout, place]
created: 2026-07-27
type: atomic-note
---

# The Place Geometry Manager

#layout #place

`.place()` positions a widget at exact coordinates within its parent. It's the least-used manager because it doesn't adapt to resizing or content changes automatically.

```python
tk.Label(root, text="Overlay badge").place(x=10, y=10)

# relative placement (0.0–1.0), scales with parent size:
tk.Label(root, text="Centered").place(relx=0.5, rely=0.5, anchor="center")
```

Legitimate use cases:
- Overlaying a widget on top of a canvas or image (e.g. a "loading" badge on a StegoForge-style preview pane)
- Pixel-perfect splash screens
- Custom draggable elements

Avoid it for standard forms/layouts — you'll fight it on every resize. Prefer [[grid-geometry-manager]].

See also: [[geometry-manager-overview]], [[canvas-widget]]

---
📍 Part of [[02 Geometry Managers MOC|Geometry Managers MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
