---
title: "The after Method for Timers and Non Blocking Delays"
domain: "04-events-and-binding"
tags: [events, timing, concurrency]
created: 2026-07-27
type: atomic-note
---

# The after Method for Timers and Non Blocking Delays

#events #timing #concurrency

`.after(ms, callback)` schedules `callback` to run once, `ms` milliseconds from now, **without blocking the event loop**. It's Tkinter's built-in alternative to `time.sleep()` inside a callback.

```python
def tick():
    label.config(text=f"Elapsed: {count[0]}s")
    count[0] += 1
    root.after(1000, tick)   # reschedule itself — a self-driving timer loop

count = [0]
root.after(1000, tick)
```

Common uses:
- Polling a queue for results from a background thread (see [[threading-with-tkinter]])
- Debouncing rapid events (e.g. search-as-you-type — cancel and reschedule on each keystroke via `.after_cancel(id)`)
- Simple animations or auto-refreshing status displays

`.after_cancel(after_id)` cancels a pending scheduled call — save the ID returned by `.after()` if you'll need to cancel it.

See also: [[the-event-loop]], [[threading-with-tkinter]]

---
📍 Part of [[04 Events and Binding MOC|Events and Binding MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
