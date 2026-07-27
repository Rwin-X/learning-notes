---
title: "Never Mix Geometry Managers In One Parent"
domain: "02-geometry-managers"
tags: [layout, pitfall]
created: 2026-07-27
type: atomic-note
---

# Never Mix Geometry Managers In One Parent

#layout #pitfall

**Rule:** within a single parent widget, use only one of `pack()`, `grid()`, or `place()`. Mixing them in the same parent causes Tkinter to freeze or deadlock the layout — this is a well-known gotcha, not a rare edge case.

```python
# ❌ BROKEN — root uses both pack and grid
tk.Label(root, text="A").pack()
tk.Label(root, text="B").grid(row=0, column=0)   # conflicts with pack in same parent
```

The fix is [[frame-widget]]: give each layout "region" its own Frame, and mix managers *across* frames freely.

```python
top_frame = tk.Frame(root)
top_frame.pack(fill="x")                 # pack used in root
tk.Label(top_frame, text="A").grid(row=0, column=0)  # grid used inside top_frame — fine
```

See also: [[frame-widget]], [[geometry-manager-overview]]

---
📍 Part of [[02 Geometry Managers MOC|Geometry Managers MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
