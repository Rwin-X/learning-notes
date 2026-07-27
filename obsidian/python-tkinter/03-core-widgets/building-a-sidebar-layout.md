---
title: "Building a Sidebar Layout Worked Example"
domain: "03-core-widgets"
tags: [widgets, layout, worked-example]
created: 2026-07-27
type: atomic-note
---

# Building a Sidebar Layout Worked Example

#widgets #layout #worked-example

A dark-themed sidebar + main-panel shell — the skeleton you'll reuse for most devforge tool GUIs (PacketForge, StegoForge-style layouts). Combines [[frame-widget]], [[pack-geometry-manager]], and [[dark-mode-color-palette]].

```python
import tkinter as tk

BG_DARK, BG_PANEL, FG_GREEN = "#0d1117", "#161b22", "#00ff9f"

root = tk.Tk()
root.title("Tool Shell")
root.geometry("700x450")
root.configure(bg=BG_DARK)

# sidebar — fixed width, docked left
sidebar = tk.Frame(root, bg=BG_PANEL, width=180)
sidebar.pack(side="left", fill="y")
sidebar.pack_propagate(False)  # stop children from shrinking the frame to fit

for label_text in ["Dashboard", "Scan", "Reports", "Settings"]:
    tk.Label(sidebar, text=label_text, bg=BG_PANEL, fg=FG_GREEN,
              anchor="w", padx=15, pady=10, font=("JetBrains Mono", 10)).pack(fill="x")

# main content — expands to fill remaining space
main = tk.Frame(root, bg=BG_DARK)
main.pack(side="right", fill="both", expand=True)
tk.Label(main, text="Main Content Area", bg=BG_DARK, fg=FG_GREEN).pack(padx=20, pady=20)

root.mainloop()
```

`pack_propagate(False)` is the key detail: without it, a Frame shrinks to fit its children, undermining a fixed-width sidebar the moment content changes.

See also: [[frame-widget]], [[dark-mode-color-palette]], [[building-a-log-console]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
