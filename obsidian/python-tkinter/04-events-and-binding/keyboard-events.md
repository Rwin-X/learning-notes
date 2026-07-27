---
title: "Keyboard Events"
domain: "04-events-and-binding"
tags: [events, keyboard]
created: 2026-07-27
type: atomic-note
---

# Keyboard Events

#events #keyboard

Keyboard event strings follow Tk's `<Modifier-Key>` naming convention.

```python
root.bind("<Return>", handler)          # Enter key
root.bind("<KeyPress>", handler)        # any key down
root.bind("<KeyRelease>", handler)      # any key up
root.bind("<Control-s>", save_handler)  # Ctrl+S — common for "save" shortcuts
root.bind("<Control-Shift-N>", handler) # multi-modifier combo
entry.bind("<Key>", live_validate)      # fires on every keystroke, before it lands
```

For live input validation (e.g. rejecting non-hex characters as they're typed into a hash-input field), `<KeyRelease>` is usually more reliable than `<Key>` since it fires *after* the character is inserted, so `entry.get()` reflects the new value.

See also: [[binding-events]], [[event-object-attributes]], [[entry-widget]]

---
📍 Part of [[04 Events and Binding MOC|Events and Binding MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
