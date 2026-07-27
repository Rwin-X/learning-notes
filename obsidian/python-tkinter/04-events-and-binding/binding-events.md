---
title: "Binding Events With bind"
domain: "04-events-and-binding"
tags: [events, bind]
created: 2026-07-27
type: atomic-note
---

# Binding Events With bind

#events #bind

`.bind(event, callback)` attaches a handler to a widget for a specific event string. This is more general than `Button`'s `command` — it works on *any* widget for *any* event type.

```python
def on_enter_key(event):
    print("Enter pressed, entry contains:", event.widget.get())

entry = tk.Entry(root)
entry.bind("<Return>", on_enter_key)

root.bind("<Escape>", lambda event: root.destroy())  # bind at window level
```

The callback always receives an `event` object with useful attributes: `event.widget`, `event.x`/`event.y` (for mouse events), `event.keysym` (for key events), `event.char`.

Binding scope matters: `.bind()` on a specific widget fires only for that widget; `.bind_all()` fires globally regardless of focus. Prefer scoped binds unless you specifically need global hotkeys.

See also: [[keyboard-events]], [[mouse-events]], [[event-object-attributes]]

---
📍 Part of [[04 Events and Binding MOC|Events and Binding MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
