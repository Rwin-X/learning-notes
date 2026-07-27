---
title: "The Event Loop"
domain: "01-core-concepts"
tags: [core, events]
created: 2026-07-27
type: atomic-note
---

# The Event Loop

#core #events

`root.mainloop()` starts Tkinter's event loop: an infinite cycle that waits for events (clicks, key presses, timers, window redraws) and dispatches them to the right handler.

```
while app is running:
    wait for an event
    find the widget it belongs to
    call that widget's bound callback
    repaint if needed
```

Critical consequence: **the event loop is single-threaded.** Any long-running function you call from inside a callback *blocks the whole GUI* — no redraws, no clicks register — until it returns. This is why [[threading-with-tkinter]] and [[the-after-method]] exist.

```python
def on_click():
    time.sleep(5)   # ❌ freezes the entire UI for 5 seconds

def on_click():
    root.after(0, long_task)  # ✅ schedule without blocking — see [[the-after-method]]
```

See also: [[root-window]], [[binding-events]], [[threading-with-tkinter]], [[the-after-method]]

---
📍 Part of [[01 Core Concepts MOC|Core Concepts MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
