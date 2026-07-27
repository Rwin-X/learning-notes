---
title: "Working With Fonts"
domain: "07-styling-and-themes"
tags: [styling, fonts]
created: 2026-07-27
type: atomic-note
---

# Working With Fonts

#styling #fonts

Fonts can be set as a simple tuple or via the `tkinter.font` module for more control (measuring text, dynamic resizing).

```python
import tkinter as tk
from tkinter import font

label = tk.Label(root, text="Hello", font=("JetBrains Mono", 12, "bold"))

# tkinter.font.Font object — needed for dynamic updates or measuring
title_font = font.Font(family="JetBrains Mono", size=16, weight="bold")
label2 = tk.Label(root, text="Title", font=title_font)
title_font.configure(size=20)  # updates label2 automatically — Font objects are live references
```

Availability caveat: a font name is only usable if it's actually installed on the user's system — Tkinter silently falls back to a default font rather than erroring, so always test on a machine where your chosen font (e.g. JetBrains Mono) isn't pre-installed to see the fallback behavior.

See also: [[dark-mode-color-palette]], [[label-widget]]

---
📍 Part of [[07 Styling and Themes MOC|Styling and Themes MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
