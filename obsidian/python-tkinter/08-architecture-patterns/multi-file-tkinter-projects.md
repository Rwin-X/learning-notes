---
title: "Structuring a Multi File Tkinter Project"
domain: "08-architecture-patterns"
tags: [architecture, project-structure]
created: 2026-07-27
type: atomic-note
---

# Structuring a Multi File Tkinter Project

#architecture #project-structure

A conventional layout for a Tkinter app beyond single-file scripts, mirroring how your devforge PySide6 projects are already organized:

```
myapp/
├── main.py              # entry point — creates App(), calls mainloop()
├── app.py                # main App(tk.Tk) class — see [[class-based-tkinter-apps]]
├── views/
│   ├── __init__.py
│   ├── sidebar.py        # Frame subclasses per UI region
│   └── main_panel.py
├── models/
│   ├── __init__.py
│   └── scan_model.py     # pure logic, no tkinter imports — see [[mvc-lite-pattern]]
├── theme.py               # color/font constants — see [[dark-mode-color-palette]]
├── assets/
│   └── icon.png
└── tests/
    └── test_scan_model.py  # pytest against models/, no GUI needed
```

Key discipline: **models/ never imports tkinter.** This is what makes the logic testable with plain `pytest` — the same separation you already enforce in your password manager between the crypto layer and the PyQt6 UI layer.

See also: [[mvc-lite-pattern]], [[class-based-tkinter-apps]]

---
📍 Part of [[08 Architecture Patterns MOC|Architecture Patterns MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
