---
title: "Button Widget"
domain: "03-core-widgets"
tags: [widgets, button]
created: 2026-07-27
type: atomic-note
---

# Button Widget

#widgets #button

`Button` triggers a callback via the `command` parameter — the primary way user actions turn into code execution.

```python
def on_scan():
    print("Scanning...")

tk.Button(root, text="Run Scan", command=on_scan, bg="#00ff9f", fg="#000000")
```

Three ways to wire a callback:
1. `command=on_scan` — no arguments passed, the common case
2. `command=lambda: on_scan(target_ip)` — pass arguments
3. Bind directly with [[binding-events]] for more control (e.g. distinguishing left/right click)

`button.config(state="disabled")` / `state="normal"` toggles it — the standard way to prevent double-submission during a long-running task (pair with [[threading-with-tkinter]]).

See also: [[binding-events]], [[tkinter-variables]], [[threading-with-tkinter]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
