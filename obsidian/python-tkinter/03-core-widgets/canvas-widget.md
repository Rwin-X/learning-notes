---
title: "Canvas Widget"
domain: "03-core-widgets"
tags: [widgets, canvas, drawing]
created: 2026-07-27
type: atomic-note
---

# Canvas Widget

#widgets #canvas #drawing

`Canvas` is a free-form drawing surface — lines, shapes, text, and images at arbitrary coordinates. It's what you'd reach for to build custom visualizations (relevant given your black-hole-simulator and PixelArt-generator background).

```python
canvas = tk.Canvas(root, width=400, height=300, bg="#0d1117")
canvas.pack()

canvas.create_line(0, 0, 400, 300, fill="#00ff9f", width=2)
canvas.create_rectangle(50, 50, 150, 100, outline="#00ff9f", fill="")
oval_id = canvas.create_oval(200, 150, 260, 210, fill="cyan")

canvas.move(oval_id, 10, 0)          # shift the oval
canvas.itemconfig(oval_id, fill="red")  # restyle it
```

Every `create_*` call returns an ID you use later to move, restyle, or delete that specific item — Canvas objects are addressable, not just drawn-and-forgotten.

See also: [[place-geometry-manager]], [[image-in-labels]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
