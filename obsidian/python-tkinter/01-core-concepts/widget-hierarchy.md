---
title: "Widget Hierarchy and Parent Child"
domain: "01-core-concepts"
tags: [core, widgets]
created: 2026-07-27
type: atomic-note
---

# Widget Hierarchy and Parent Child

#core #widgets

Every widget in Tkinter has a **parent** (also called "master"), forming a tree rooted at the [[root-window]]. This mirrors the DOM or a filesystem tree.

```python
root = tk.Tk()
frame = tk.Frame(root)          # frame's parent is root
label = tk.Label(frame, text="Hi")  # label's parent is frame
```

Why this matters:
- Destroying a parent destroys all its children (`frame.destroy()` wipes `label` too).
- Geometry managers ([[pack-geometry-manager]], [[grid-geometry-manager]]) operate **within a parent** — children of different parents don't interact positionally.
- [[frame-widget]] exists specifically to group widgets into sub-trees for layout control.

Think of it like nested folders: you can't `grid()` a widget from inside `frame` next to a widget that lives directly in `root` — they're in different layout "namespaces."

See also: [[root-window]], [[frame-widget]], [[pack-geometry-manager]]

---
📍 Part of [[01 Core Concepts MOC|Core Concepts MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
