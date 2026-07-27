---
title: "Mouse Events"
domain: "04-events-and-binding"
tags: [events, mouse]
created: 2026-07-27
type: atomic-note
---

# Mouse Events

#events #mouse

```python
widget.bind("<Button-1>", handler)        # left click
widget.bind("<Button-3>", handler)        # right click — common for context menus
widget.bind("<Double-Button-1>", handler) # double-click
widget.bind("<B1-Motion>", handler)       # dragging with left button held
widget.bind("<Enter>", handler)           # mouse enters widget bounds (hover start)
widget.bind("<Leave>", handler)           # mouse leaves widget bounds (hover end)
widget.bind("<MouseWheel>", handler)      # scroll wheel (delta sign/magnitude is platform-dependent)
```

Right-click context menus are a common pattern combining `<Button-3>` with a `Menu` widget's `.tk_popup(event.x_root, event.y_root)`.

`<Enter>`/`<Leave>` are the basis for hover-highlight effects — pair with `.config(bg=...)` to build a lightweight custom-styled button before reaching for full [[styling-with-ttk]].

See also: [[binding-events]], [[event-object-attributes]]

---
📍 Part of [[04 Events and Binding MOC|Events and Binding MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
