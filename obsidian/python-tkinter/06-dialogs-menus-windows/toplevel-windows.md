---
title: "Toplevel Windows"
domain: "06-dialogs-menus-windows"
tags: [windows, toplevel]
created: 2026-07-27
type: atomic-note
---

# Toplevel Windows

#windows #toplevel

`Toplevel` creates an additional window beyond the [[root-window]] — a settings dialog, an about box, a secondary tool panel. Never call `tk.Tk()` a second time; always use `Toplevel`.

```python
def open_settings():
    win = tk.Toplevel(root)
    win.title("Settings")
    win.geometry("300x200")
    tk.Label(win, text="Settings go here").pack(pady=20)

    win.transient(root)   # ties it to the root window (minimizes together, etc.)
    win.grab_set()        # makes it modal — blocks interaction with root until closed

tk.Button(root, text="Settings", command=open_settings).pack()
```

`.grab_set()` makes a window **modal** (must be closed before returning to the parent) — appropriate for confirmation dialogs, inappropriate for a persistent tool palette the user should be able to ignore.

See also: [[root-window]], [[messagebox-dialogs]]

---
📍 Part of [[06 Dialogs Menus and Windows MOC|Dialogs Menus and Windows MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
