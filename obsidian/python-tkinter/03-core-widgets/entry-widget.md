---
title: "Entry Widget"
domain: "03-core-widgets"
tags: [widgets, entry, input]
created: 2026-07-27
type: atomic-note
---

# Entry Widget

#widgets #entry #input

`Entry` is a single-line text input.

```python
entry = tk.Entry(root, width=30, show="*")   # show="*" masks input — password fields
entry.insert(0, "default text")               # pre-fill
value = entry.get()                           # read current value
entry.delete(0, "end")                        # clear
```

Validation hook (useful for OSINT/cybersecurity tool inputs like IP fields):

```python
def validate_ip(new_value):
    return all(c.isdigit() or c == "." for c in new_value)

vcmd = (root.register(validate_ip), "%P")
tk.Entry(root, validate="key", validatecommand=vcmd)
```

For multi-line input use [[text-widget]] instead.

See also: [[text-widget]], [[tkinter-variables]], [[building-a-form-layout]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
