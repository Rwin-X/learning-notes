---
title: "Scrollbar Widget"
domain: "03-core-widgets"
tags: [widgets, scrollbar]
created: 2026-07-27
type: atomic-note
---

# Scrollbar Widget

#widgets #scrollbar

`Scrollbar` doesn't scroll anything by itself — it must be explicitly linked to a scrollable widget ([[text-widget]], `Listbox`, `Canvas`) via `.config(command=...)` and `.config(yscrollcommand=...)`. This two-way wiring trips up almost everyone the first time.

```python
text = tk.Text(root, wrap="none")
scroll_y = tk.Scrollbar(root, orient="vertical", command=text.yview)
text.config(yscrollcommand=scroll_y.set)

text.grid(row=0, column=0, sticky="nsew")
scroll_y.grid(row=0, column=1, sticky="ns")
```

The pattern is symmetric: the scrollbar tells the widget where to scroll (`command`), and the widget tells the scrollbar where it currently is (`yscrollcommand`). Skip either half and you get a scrollbar that either doesn't move the content, or doesn't reflect the current position.

See also: [[text-widget]], [[canvas-widget]], [[building-a-log-console]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
