---
title: "ttk Themed Widgets"
domain: "07-styling-and-themes"
tags: [styling, ttk]
created: 2026-07-27
type: atomic-note
---

# ttk Themed Widgets

#styling #ttk

`ttk` (Tk Themed widgets) is a parallel widget set that respects OS/theme styling and looks dramatically less dated than classic `tk` widgets. Prefer `ttk` versions whenever one exists.

```python
from tkinter import ttk

ttk.Button(root, text="Click me").pack()
ttk.Entry(root).pack()
ttk.Label(root, text="Styled label").pack()
ttk.Combobox(root, values=["A", "B"]).pack()   # no plain-tk equivalent
ttk.Progressbar(root, mode="determinate").pack()  # no plain-tk equivalent
ttk.Treeview(root)  # table/tree view — no plain-tk equivalent
```

Important gotcha: `ttk` widgets **don't accept `bg`/`fg` directly** the way classic `tk` widgets do — you style them through [[styling-with-ttk]]'s `Style` object instead. Mixing `tk.Button(bg=...)` and `ttk.Button` styling approaches in one app is a common source of "why won't this color apply" confusion.

See also: [[styling-with-ttk]], [[button-widget]], [[listbox-and-combobox]]

---
📍 Part of [[07 Styling and Themes MOC|Styling and Themes MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
