---
title: "The Event Object"
domain: "04-events-and-binding"
tags: [events, reference]
created: 2026-07-27
type: atomic-note
---

# The Event Object

#events #reference

Every bound callback receives one `event` argument carrying details about what happened. Useful attributes by event category:

| Attribute | Meaning | Relevant for |
|---|---|---|
| `event.widget` | The widget that triggered the event | All events |
| `event.x`, `event.y` | Mouse position relative to widget | Mouse events |
| `event.x_root`, `event.y_root` | Mouse position relative to screen | Mouse events |
| `event.keysym` | Symbolic key name (`"Return"`, `"a"`, `"Escape"`) | Key events |
| `event.char` | The actual character typed (empty for non-printable) | Key events |
| `event.num` | Which mouse button (1=left, 2=middle, 3=right) | Click events |

```python
def log_click(event):
    print(f"Clicked {event.widget} at ({event.x}, {event.y}) with button {event.num}")

widget.bind("<Button-1>", log_click)
```

See also: [[binding-events]], [[keyboard-events]], [[mouse-events]]

---
📍 Part of [[04 Events and Binding MOC|Events and Binding MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
