---
title: "Frame Widget"
domain: "03-core-widgets"
tags: [widgets, frame, layout]
created: 2026-07-27
type: atomic-note
---

# Frame Widget

#widgets #frame #layout

`Frame` is an invisible (by default) container used purely to group and organize other widgets — the layout equivalent of a `<div>`.

```python
sidebar = tk.Frame(root, bg="#161b22", width=200)
sidebar.pack(side="left", fill="y")

main = tk.Frame(root, bg="#0d1117")
main.pack(side="right", fill="both", expand=True)
```

Why you'll use it constantly:
- Solves [[mixing-geometry-managers-warning]] — each Frame is its own layout namespace
- Groups related widgets for show/hide (`.pack_forget()` / `.pack()` an entire frame at once)
- Building block for [[building-a-sidebar-layout]] patterns common in your devforge dark-UI tools

`LabelFrame` is a variant with a visible border and title — handy for grouping form sections ("Connection Settings", "Output Options").

See also: [[widget-hierarchy]], [[mixing-geometry-managers-warning]], [[building-a-sidebar-layout]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
