---
title: "Building a Dark Terminal Aesthetic"
domain: "07-styling-and-themes"
tags: [styling, theme, dark-mode]
created: 2026-07-27
type: atomic-note
---

# Building a Dark Terminal Aesthetic

#styling #theme #dark-mode

A reusable color/font constants module matching the phosphor-green/cyan cyberpunk aesthetic across your devforge tools (StegoForge, PacketForge, etc.) — define once, import everywhere.

```python
# theme.py
BG_DARK   = "#0d1117"
BG_PANEL  = "#161b22"
FG_GREEN  = "#00ff9f"
FG_CYAN   = "#39d5ff"
FG_MUTED  = "#8b949e"
FG_ERROR  = "#ff4444"
FONT_MONO = ("JetBrains Mono", 10)
FONT_MONO_BOLD = ("JetBrains Mono", 10, "bold")

def apply_dark_root(root):
    root.configure(bg=BG_DARK)
```

Usage across widgets:

```python
from theme import BG_DARK, FG_GREEN, FONT_MONO

label = tk.Label(root, text="STATUS: ONLINE", bg=BG_DARK, fg=FG_GREEN, font=FONT_MONO)
```

For `ttk` widgets, feed these same constants into [[styling-with-ttk]]'s `style.configure()` calls instead of setting them per-widget — one source of truth for the whole app's palette.

See also: [[styling-with-ttk]], [[ttk-themed-widgets]]

---
📍 Part of [[07 Styling and Themes MOC|Styling and Themes MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
