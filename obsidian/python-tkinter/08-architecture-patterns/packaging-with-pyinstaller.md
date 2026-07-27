---
title: "Packaging a Tkinter App With PyInstaller"
domain: "08-architecture-patterns"
tags: [architecture, packaging, distribution]
created: 2026-07-27
type: atomic-note
---

# Packaging a Tkinter App With PyInstaller

#architecture #packaging #distribution

`PyInstaller` bundles a Tkinter app plus the Python interpreter into a single distributable executable — no "install Python first" requirement for end users.

```bash
pip install pyinstaller

# one-file executable, no console window (GUI app):
pyinstaller --onefile --windowed --name MyApp main.py

# with an icon and bundled assets:
pyinstaller --onefile --windowed --icon=assets/icon.ico \
    --add-data "assets;assets" main.py   # Windows separator is ';' — use ':' on macOS/Linux
```

Common gotchas:
- `--windowed` (alias `--noconsole`) suppresses the terminal window on Windows/macOS — omit it while debugging so you can see `print()`/tracebacks.
- Asset paths (images, fonts) that work in dev break in the bundled `.exe` unless you resolve them via `sys._MEIPASS` at runtime — PyInstaller extracts bundled files to a temp folder.
- Output lands in `dist/` — that's the file you actually ship.

```python
import sys, os

def resource_path(relative_path):
    base = getattr(sys, "_MEIPASS", os.path.dirname(__file__))
    return os.path.join(base, relative_path)
```

See also: [[multi-file-tkinter-projects]], [[image-in-labels]]

---
📍 Part of [[08 Architecture Patterns MOC|Architecture Patterns MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
