---
title: "Label Widget"
domain: "03-core-widgets"
tags: [widgets, label]
created: 2026-07-27
type: atomic-note
---

# Label Widget

#widgets #label

`Label` displays text or an image — it's read-only, non-interactive.

```python
tk.Label(root, text="Status: Ready", font=("JetBrains Mono", 11), fg="#00ff9f", bg="#0d1117")
```

Common options: `text`, `textvariable` (see [[tkinter-variables]]), `font`, `fg`/`bg`, `image` (see [[image-in-labels]]), `wraplength` (wrap text at N pixels), `justify`.

For status text that changes at runtime, bind a `StringVar` via `textvariable` rather than repeatedly calling `.config(text=...)` — it's the idiomatic pattern and plays nicer with [[tkinter-variables]]-driven architecture.

See also: [[button-widget]], [[tkinter-variables]], [[styling-with-ttk]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
