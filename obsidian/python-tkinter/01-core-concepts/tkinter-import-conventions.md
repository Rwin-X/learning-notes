---
title: "Import Conventions"
domain: "01-core-concepts"
tags: [core, syntax]
created: 2026-07-27
type: atomic-note
---

# Import Conventions

#core #syntax

Standard imports you'll see across every Tkinter codebase:

```python
import tkinter as tk
from tkinter import ttk                       # themed widgets — see [[ttk-themed-widgets]]
from tkinter import messagebox, filedialog     # see [[messagebox-dialogs]], [[filedialog-usage]]
from tkinter import font as tkfont
```

Avoid `from tkinter import *` — it dumps ~150 names into your namespace and silently shadows built-ins (`tk.Label` reads better than a bare `Label` fighting with your own classes anyway). This matches the explicit-import discipline you already use in your devforge PySide6 projects.

See also: [[what-is-tkinter]], [[ttk-themed-widgets]]

---
📍 Part of [[01 Core Concepts MOC|Core Concepts MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
