---
title: "Styling ttk Widgets With Style"
domain: "07-styling-and-themes"
tags: [styling, ttk, theme]
created: 2026-07-27
type: atomic-note
---

# Styling ttk Widgets With Style

#styling #ttk #theme

`ttk.Style()` is how you actually recolor/restyle `ttk` widgets — direct `bg=`/`fg=` kwargs are ignored or limited on most ttk widgets.

```python
from tkinter import ttk

style = ttk.Style()
style.theme_use("clam")   # 'clam' themes best for custom colors; try 'alt', 'default', 'classic' too

style.configure(
    "Dark.TButton",
    background="#0d1117",
    foreground="#00ff9f",
    font=("JetBrains Mono", 10),
    borderwidth=0,
)
style.map("Dark.TButton", background=[("active", "#161b22")])  # hover/pressed state

ttk.Button(root, text="Scan", style="Dark.TButton").pack()
```

Pattern: define a **named style** (`"Dark.TButton"`) rather than restyling the base `"TButton"` globally — this lets you have both a normal button and a "danger" red-styled button coexisting.

`style.map()` handles state-dependent styling (`active` = hovered/pressed, `disabled`) — this is the ttk equivalent of CSS `:hover`.

See also: [[ttk-themed-widgets]], [[dark-mode-color-palette]]

---
📍 Part of [[07 Styling and Themes MOC|Styling and Themes MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
