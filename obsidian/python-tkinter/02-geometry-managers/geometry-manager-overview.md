---
title: "Geometry Manager Overview"
domain: "02-geometry-managers"
tags: [layout, overview]
created: 2026-07-27
type: atomic-note
---

# Geometry Manager Overview

#layout #overview

Tkinter has three independent layout systems. **Never mix two of them inside the same parent** — that's the single most common bug new Tkinter developers hit.

| Manager | Model | Best for |
|---|---|---|
| [[pack-geometry-manager]] | Stack widgets against a side | Simple vertical/horizontal stacks, toolbars |
| [[grid-geometry-manager]] | Row/column table | Forms, structured layouts — most common choice |
| [[place-geometry-manager]] | Absolute x/y coordinates | Overlays, pixel-precise placement (rare) |

Rule of thumb: **default to `grid()`** for anything beyond a trivial single-column layout. It's the closest thing Tkinter has to CSS Grid and scales better than `pack()` as UIs grow.

See also: [[pack-geometry-manager]], [[grid-geometry-manager]], [[place-geometry-manager]], [[mixing-geometry-managers-warning]]

---
📍 Part of [[02 Geometry Managers MOC|Geometry Managers MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
