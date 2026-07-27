---
title: "File Dialogs"
domain: "06-dialogs-menus-windows"
tags: [windows, dialogs, files]
created: 2026-07-27
type: atomic-note
---

# File Dialogs

#windows #dialogs #files

`tkinter.filedialog` provides native open/save file pickers — essential for any tool that reads/writes files (directly relevant to StegoForge, CryptForge-style file-based tools).

```python
from tkinter import filedialog

path = filedialog.askopenfilename(
    title="Select image",
    filetypes=[("PNG images", "*.png"), ("All files", "*.*")]
)

save_path = filedialog.asksaveasfilename(
    defaultextension=".txt",
    filetypes=[("Text files", "*.txt")]
)

folder = filedialog.askdirectory(title="Select output folder")
```

All three return an empty string (`""`) if the user cancels — always check before using the result:

```python
if not path:
    return  # user cancelled, bail out cleanly
```

See also: [[messagebox-dialogs]], [[entry-widget]]

---
📍 Part of [[06 Dialogs Menus and Windows MOC|Dialogs Menus and Windows MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
