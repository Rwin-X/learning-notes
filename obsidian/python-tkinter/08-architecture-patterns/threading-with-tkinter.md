---
title: "Threading With Tkinter"
domain: "08-architecture-patterns"
tags: [architecture, concurrency, threading]
created: 2026-07-27
type: atomic-note
---

# Threading With Tkinter

#architecture #concurrency #threading

Tkinter is **not thread-safe** — you must never touch a widget from any thread other than the main thread. But long tasks (network scans, file hashing) can't block [[the-event-loop]] either. The standard fix: run the work in a background thread, and pass results back through a `queue.Queue`, polled via [[the-after-method]].

```python
import threading
import queue
import tkinter as tk

class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.result_queue = queue.Queue()
        tk.Button(self, text="Start Scan", command=self.start_scan).pack()
        self.label = tk.Label(self, text="Idle")
        self.label.pack()
        self.after(100, self.poll_queue)

    def start_scan(self):
        self.label.config(text="Scanning...")
        threading.Thread(target=self.worker, daemon=True).start()

    def worker(self):
        # runs in background thread — NEVER touch self.label here directly
        import time
        time.sleep(3)
        self.result_queue.put("Scan complete: 3 hosts found")

    def poll_queue(self):
        try:
            message = self.result_queue.get_nowait()
            self.label.config(text=message)   # safe — this runs on the main thread
        except queue.Empty:
            pass
        self.after(100, self.poll_queue)   # keep polling
```

`daemon=True` on the thread ensures it won't block app exit if it's still running when the window closes. This exact pattern is what you'll want for any devforge GUI wrapping a slow CLI tool (TraceForge, DigitForge) behind a responsive UI.

See also: [[the-after-method]], [[the-event-loop]], [[button-widget]]

---
📍 Part of [[08 Architecture Patterns MOC|Architecture Patterns MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
