---
title: "Listbox and Combobox"
domain: "03-core-widgets"
tags: [widgets, input, ttk]
created: 2026-07-27
type: atomic-note
---

# Listbox and Combobox

#widgets #input #ttk

`Listbox` (classic tk) shows a scrollable list of selectable items; `ttk.Combobox` is a dropdown select — both common in tool GUIs for picking targets, interfaces, or presets.

```python
# Listbox
listbox = tk.Listbox(root, selectmode="multiple")
for item in ["eth0", "wlan0", "lo"]:
    listbox.insert("end", item)
selected = [listbox.get(i) for i in listbox.curselection()]

# Combobox (ttk)
from tkinter import ttk
combo = ttk.Combobox(root, values=["Low", "Medium", "High"], state="readonly")
combo.set("Medium")
combo.pack()
print(combo.get())
```

`state="readonly"` on Combobox prevents free-typing — forces selection from the list, useful for constrained option sets (e.g. scan intensity levels).

See also: [[ttk-themed-widgets]], [[scrollbar-widget]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
