---
title: "Displaying Images"
domain: "03-core-widgets"
tags: [widgets, images]
created: 2026-07-27
type: atomic-note
---

# Displaying Images

#widgets #images

Tkinter's built-in `PhotoImage` only supports GIF/PGM/PPM/PNG (PNG support depends on Tcl/Tk version). For JPEG or reliable cross-format support, use **Pillow**.

```python
import tkinter as tk
from PIL import Image, ImageTk   # pip install pillow

img = Image.open("logo.png").resize((100, 100))
photo = ImageTk.PhotoImage(img)

label = tk.Label(root, image=photo)
label.image = photo   # ⚠️ MUST keep a reference — see gotcha below
label.pack()
```

**The #1 Tkinter image gotcha:** if nothing in Python keeps a reference to the `PhotoImage` object, the garbage collector frees it and your image silently vanishes (blank widget, no error). Storing it as `label.image = photo`, or in a list/dict on `self` in a class-based app, prevents this.

See also: [[label-widget]], [[canvas-widget]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
