---
title: "Checkbutton and Radiobutton"
domain: "03-core-widgets"
tags: [widgets, input]
created: 2026-07-27
type: atomic-note
---

# Checkbutton and Radiobutton

#widgets #input

`Checkbutton` (boolean toggle) and `Radiobutton` (mutually exclusive choice) both bind to [[tkinter-variables]] rather than being read with `.get()` directly on the widget.

```python
verbose = tk.BooleanVar(value=False)
tk.Checkbutton(root, text="Verbose output", variable=verbose).pack()

mode = tk.StringVar(value="tcp")
tk.Radiobutton(root, text="TCP", variable=mode, value="tcp").pack()
tk.Radiobutton(root, text="UDP", variable=mode, value="udp").pack()

# later:
if verbose.get():
    ...
print(mode.get())  # "tcp" or "udp"
```

All `Radiobutton`s sharing the same `variable` are automatically mutually exclusive — no manual "uncheck the others" logic needed.

See also: [[tkinter-variables]], [[button-widget]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
