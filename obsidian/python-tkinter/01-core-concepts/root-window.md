---
title: "The Root Window"
domain: "01-core-concepts"
tags: [core, window]
created: 2026-07-27
type: atomic-note
---

# The Root Window

#core #window

Every Tkinter app begins with exactly one root window — the top-level container everything else lives inside.

```python
import tkinter as tk

root = tk.Tk()          # the root window — create this ONCE
root.title("My App")
root.geometry("400x300")  # width x height in pixels
root.mainloop()          # blocks here — see [[the-event-loop]]
```

Rules:
- Only call `tk.Tk()` **once** per process. For additional windows use [[toplevel-windows]], not a second `Tk()`.
- Nothing appears on screen until `.mainloop()` runs.
- `root.geometry("WxH+X+Y")` sets size and optionally screen position.

See also: [[the-event-loop]], [[toplevel-windows]], [[widget-hierarchy]]

---
📍 Part of [[01 Core Concepts MOC|Core Concepts MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
