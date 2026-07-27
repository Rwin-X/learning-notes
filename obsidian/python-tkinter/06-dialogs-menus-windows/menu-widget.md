---
title: "Menu Bars and Context Menus"
domain: "06-dialogs-menus-windows"
tags: [windows, menu]
created: 2026-07-27
type: atomic-note
---

# Menu Bars and Context Menus

#windows #menu

`Menu` builds both top-level menu bars (File/Edit/Help) and right-click context menus.

```python
menubar = tk.Menu(root)
root.config(menu=menubar)

file_menu = tk.Menu(menubar, tearoff=0)
file_menu.add_command(label="Open...", command=open_file, accelerator="Ctrl+O")
file_menu.add_command(label="Save", command=save_file, accelerator="Ctrl+S")
file_menu.add_separator()
file_menu.add_command(label="Exit", command=root.quit)
menubar.add_cascade(label="File", menu=file_menu)

# context menu (right-click)
context = tk.Menu(root, tearoff=0)
context.add_command(label="Copy", command=copy_selection)

def show_context(event):
    context.tk_popup(event.x_root, event.y_root)

root.bind("<Button-3>", show_context)
```

`tearoff=0` removes the old-fashioned dashed line that lets users "tear off" a menu into its own window — almost always what you want for a modern-looking app. `accelerator=` is *display-only text* — you still need a separate `root.bind("<Control-o>", open_file)` to make the shortcut actually work.

See also: [[binding-events]], [[toplevel-windows]]

---
📍 Part of [[06 Dialogs Menus and Windows MOC|Dialogs Menus and Windows MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
