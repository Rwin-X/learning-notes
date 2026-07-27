---
title: "Tkinter Variable Types Overview"
domain: "05-variables-and-state"
tags: [state, variables]
created: 2026-07-27
type: atomic-note
---

# Tkinter Variable Types Overview

#state #variables

Tkinter provides four variable wrapper classes that link Python state directly to widgets: `StringVar`, `IntVar`, `DoubleVar`, `BooleanVar`. They're the closest Tkinter gets to reactive/two-way data binding.

```python
name = tk.StringVar(value="")
count = tk.IntVar(value=0)
ratio = tk.DoubleVar(value=0.0)
enabled = tk.BooleanVar(value=True)

entry = tk.Entry(root, textvariable=name)  # typing updates `name` automatically
label = tk.Label(root, textvariable=name)  # label text updates automatically too
```

Why use these instead of `.get()`/`.insert()` on the widget directly?
- One variable can drive **multiple widgets** in sync (an Entry and a Label both showing the same value)
- They support [[variable-tracing]] — running a callback whenever the value changes
- They decouple your app logic from widget internals — closer to the MVC pattern in [[mvc-lite-pattern]]

See also: [[variable-tracing]], [[entry-widget]], [[mvc-lite-pattern]]

---
📍 Part of [[05 Variables and State MOC|Variables and State MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
