---
title: "Building a Log Console Worked Example"
domain: "03-core-widgets"
tags: [widgets, text, worked-example]
created: 2026-07-27
type: atomic-note
---

# Building a Log Console Worked Example

#widgets #text #worked-example

A scrollable, color-tagged log console — the pattern behind a cyber_news-style terminal panel or live scan output. Combines [[text-widget]], [[scrollbar-widget]], and tag-based coloring.

```python
import tkinter as tk

BG_DARK = "#0d1117"

root = tk.Tk()
root.title("Log Console")
root.configure(bg=BG_DARK)

frame = tk.Frame(root)
frame.pack(fill="both", expand=True, padx=10, pady=10)
frame.rowconfigure(0, weight=1)
frame.columnconfigure(0, weight=1)

log = tk.Text(frame, bg=BG_DARK, fg="#c9d1d9", insertbackground="white",
               font=("JetBrains Mono", 10), state="disabled", wrap="word")
log.grid(row=0, column=0, sticky="nsew")

scroll = tk.Scrollbar(frame, orient="vertical", command=log.yview)
scroll.grid(row=0, column=1, sticky="ns")
log.config(yscrollcommand=scroll.set)

log.tag_config("info", foreground="#39d5ff")
log.tag_config("success", foreground="#00ff9f")
log.tag_config("error", foreground="#ff4444")

def write_log(message, level="info"):
    log.config(state="normal")          # briefly unlock to write
    log.insert("end", message + "\n", level)
    log.see("end")                       # auto-scroll to newest line
    log.config(state="disabled")         # relock — read-only again

write_log("Initializing scanner...", "info")
write_log("Target acquired: 192.168.1.1", "info")
write_log("Scan complete: 3 open ports", "success")

root.mainloop()
```

`log.see("end")` is what makes it feel like a live terminal — without it, new lines append below the visible area and the user has to scroll manually to see them.

See also: [[text-widget]], [[scrollbar-widget]], [[threading-with-tkinter]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
