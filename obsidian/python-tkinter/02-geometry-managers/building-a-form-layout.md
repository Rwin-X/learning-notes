---
title: "Building a Form Layout Worked Example"
domain: "02-geometry-managers"
tags: [layout, grid, worked-example]
created: 2026-07-27
type: atomic-note
---

# Building a Form Layout Worked Example

#layout #grid #worked-example

A complete login-style form combining [[grid-geometry-manager]], [[grid-weights-and-resizing]], and [[frame-widget]] — the pattern you'll reuse constantly for devforge tool GUIs.

```python
import tkinter as tk

root = tk.Tk()
root.title("Login")

form = tk.Frame(root, padx=20, pady=20)
form.pack(fill="both", expand=True)
form.columnconfigure(1, weight=1)  # entry column stretches

tk.Label(form, text="Username:").grid(row=0, column=0, sticky="e", pady=5)
username = tk.Entry(form)
username.grid(row=0, column=1, sticky="ew", pady=5)

tk.Label(form, text="Password:").grid(row=1, column=0, sticky="e", pady=5)
password = tk.Entry(form, show="*")
password.grid(row=1, column=1, sticky="ew", pady=5)

tk.Button(form, text="Login", command=lambda: print(username.get())).grid(
    row=2, column=0, columnspan=2, pady=(10, 0)
)

root.mainloop()
```

See also: [[grid-geometry-manager]], [[entry-widget]], [[tkinter-variables]]

---
📍 Part of [[02 Geometry Managers MOC|Geometry Managers MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
