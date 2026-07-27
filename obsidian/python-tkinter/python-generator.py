#!/usr/bin/env python3
"""
Tkinter Second Brain — Obsidian Vault Generator
=================================================
Pure stdlib. Generates an atomic-note Obsidian vault for learning Tkinter,
following the RWIN devforge vault pattern (MOCs + atomic notes + wikilinks).

Usage:
    python generate_vault.py                # generate vault in ./TkinterVault
    python generate_vault.py --out <path>    # custom output dir
    python generate_vault.py --validate      # check all [[wikilinks]] resolve

MVP SCOPE (Phase 1): 8 domains, GUI-fundamentals-weighted, ~45 notes.
Designed to be re-run safely (idempotent) and extended later — add new
NOTES entries to DOMAINS below and re-run.
"""

import argparse
import re
import sys
from pathlib import Path
from datetime import date

TODAY = date.today().isoformat()

# ---------------------------------------------------------------------------
# VAULT CONTENT
# Each domain: id, title, emoji, description, list of notes.
# Each note: slug, title, tags, body (markdown, using [[wikilinks]]).
# ---------------------------------------------------------------------------

DOMAINS = [
    {
        "id": "01",
        "key": "core-concepts",
        "title": "Core Concepts",
        "emoji": "🧠",
        "desc": "The mental model of Tkinter: what a GUI app actually *is* at runtime.",
        "notes": [
            {
                "slug": "what-is-tkinter",
                "title": "What Is Tkinter",
                "tags": ["core", "overview"],
                "body": """Tkinter is Python's standard-library binding to **Tcl/Tk**, a GUI toolkit originally written in Tcl. It ships with the default CPython install on Windows and macOS (on Linux you may need `python3-tk` from your package manager).

Key facts:
- It is **not** a native-widget toolkit — Tk draws its own widgets, though modern `ttk` widgets approximate the OS theme.
- It is single-threaded by design — see [[the-event-loop]] and [[threading-with-tkinter]].
- It's "good enough" for internal tools, utilities, prototypes, and — relevant to your devforge stack — quick GUIs on top of CLI tools (PacketForge, StegoForge pattern) before graduating to PySide6/PyQt6 for production polish.

Compare mentally: Tkinter is to GUIs what `argparse` is to CLIs — built-in, unglamorous, always available.

See also: [[tkinter-vs-pyqt6]], [[root-window]], [[the-event-loop]]"""
            },
            {
                "slug": "tkinter-vs-pyqt6",
                "title": "Tkinter vs PyQt6 PySide6",
                "tags": ["core", "comparison"],
                "body": """You already ship production PySide6 apps (password manager, StegoForge, Idea Book). Here's when Tkinter is the *better* choice, not just the easier one:

| Use Tkinter when | Use PySide6/PyQt6 when |
|---|---|
| Zero-dependency requirement (stdlib only) | You need modern theming out of the box |
| Quick internal tool / one-off script GUI | Shipping a polished product |
| Teaching / learning GUI concepts fast | Complex widgets (graphs, force-directed views) |
| Air-gapped or restricted environments | You need QThread-grade concurrency tooling |

Architecturally the concepts transfer directly: [[the-event-loop]] ≈ Qt's event loop, [[widget-hierarchy]] ≈ Qt's parent/child tree, [[tkinter-variables]] ≈ Qt's signal-driven state. Learning Tkinter well makes you *faster* at PySide6, not redundant with it.

See also: [[what-is-tkinter]], [[the-event-loop]]"""
            },
            {
                "slug": "root-window",
                "title": "The Root Window",
                "tags": ["core", "window"],
                "body": """Every Tkinter app begins with exactly one root window — the top-level container everything else lives inside.

```python
import tkinter as tk

root = tk.Tk()          # the root window — create this ONCE
root.title("My App")
root.geometry("400x300")  # width x height in pixels
root.mainloop()          # blocks here — see [[the-event-loop]]
```

Rules:
- Only call `tk.Tk()` **once** per process. For additional windows use [[toplevel-windows]], not a second `Tk()`.
- Nothing appears on screen until `.mainloop()` runs.
- `root.geometry("WxH+X+Y")` sets size and optionally screen position.

See also: [[the-event-loop]], [[toplevel-windows]], [[widget-hierarchy]]"""
            },
            {
                "slug": "the-event-loop",
                "title": "The Event Loop",
                "tags": ["core", "events"],
                "body": """`root.mainloop()` starts Tkinter's event loop: an infinite cycle that waits for events (clicks, key presses, timers, window redraws) and dispatches them to the right handler.

```
while app is running:
    wait for an event
    find the widget it belongs to
    call that widget's bound callback
    repaint if needed
```

Critical consequence: **the event loop is single-threaded.** Any long-running function you call from inside a callback *blocks the whole GUI* — no redraws, no clicks register — until it returns. This is why [[threading-with-tkinter]] and [[the-after-method]] exist.

```python
def on_click():
    time.sleep(5)   # ❌ freezes the entire UI for 5 seconds

def on_click():
    root.after(0, long_task)  # ✅ schedule without blocking — see [[the-after-method]]
```

See also: [[root-window]], [[binding-events]], [[threading-with-tkinter]], [[the-after-method]]"""
            },
            {
                "slug": "widget-hierarchy",
                "title": "Widget Hierarchy and Parent Child",
                "tags": ["core", "widgets"],
                "body": """Every widget in Tkinter has a **parent** (also called "master"), forming a tree rooted at the [[root-window]]. This mirrors the DOM or a filesystem tree.

```python
root = tk.Tk()
frame = tk.Frame(root)          # frame's parent is root
label = tk.Label(frame, text="Hi")  # label's parent is frame
```

Why this matters:
- Destroying a parent destroys all its children (`frame.destroy()` wipes `label` too).
- Geometry managers ([[pack-geometry-manager]], [[grid-geometry-manager]]) operate **within a parent** — children of different parents don't interact positionally.
- [[frame-widget]] exists specifically to group widgets into sub-trees for layout control.

Think of it like nested folders: you can't `grid()` a widget from inside `frame` next to a widget that lives directly in `root` — they're in different layout "namespaces."

See also: [[root-window]], [[frame-widget]], [[pack-geometry-manager]]"""
            },
            {
                "slug": "tkinter-import-conventions",
                "title": "Import Conventions",
                "tags": ["core", "syntax"],
                "body": """Standard imports you'll see across every Tkinter codebase:

```python
import tkinter as tk
from tkinter import ttk                       # themed widgets — see [[ttk-themed-widgets]]
from tkinter import messagebox, filedialog     # see [[messagebox-dialogs]], [[filedialog-usage]]
from tkinter import font as tkfont
```

Avoid `from tkinter import *` — it dumps ~150 names into your namespace and silently shadows built-ins (`tk.Label` reads better than a bare `Label` fighting with your own classes anyway). This matches the explicit-import discipline you already use in your devforge PySide6 projects.

See also: [[what-is-tkinter]], [[ttk-themed-widgets]]"""
            },
        ],
    },
    {
        "id": "02",
        "key": "geometry-managers",
        "title": "Geometry Managers",
        "emoji": "📐",
        "desc": "How widgets get placed on screen — pack, grid, and place. The #1 source of layout confusion; worth mastering deeply.",
        "notes": [
            {
                "slug": "geometry-manager-overview",
                "title": "Geometry Manager Overview",
                "tags": ["layout", "overview"],
                "body": """Tkinter has three independent layout systems. **Never mix two of them inside the same parent** — that's the single most common bug new Tkinter developers hit.

| Manager | Model | Best for |
|---|---|---|
| [[pack-geometry-manager]] | Stack widgets against a side | Simple vertical/horizontal stacks, toolbars |
| [[grid-geometry-manager]] | Row/column table | Forms, structured layouts — most common choice |
| [[place-geometry-manager]] | Absolute x/y coordinates | Overlays, pixel-precise placement (rare) |

Rule of thumb: **default to `grid()`** for anything beyond a trivial single-column layout. It's the closest thing Tkinter has to CSS Grid and scales better than `pack()` as UIs grow.

See also: [[pack-geometry-manager]], [[grid-geometry-manager]], [[place-geometry-manager]], [[mixing-geometry-managers-warning]]"""
            },
            {
                "slug": "pack-geometry-manager",
                "title": "The Pack Geometry Manager",
                "tags": ["layout", "pack"],
                "body": """`.pack()` stacks widgets against a side of their parent, one after another, like books on a shelf.

```python
tk.Label(root, text="Top").pack(side="top")
tk.Label(root, text="Bottom").pack(side="bottom")
tk.Button(root, text="Fill me").pack(fill="x", expand=True, padx=10, pady=5)
```

Key options:
- `side`: `"top"` (default), `"bottom"`, `"left"`, `"right"`
- `fill`: `"x"`, `"y"`, or `"both"` — stretch the widget to fill available space
- `expand`: `True`/`False` — claim extra space when the window resizes
- `padx`/`pady`: outer spacing in pixels

Pack is fast for simple stacks but becomes unreadable for anything grid-like (forms, tables) — reach for [[grid-geometry-manager]] instead once you have more than ~3 widgets in a parent.

See also: [[geometry-manager-overview]], [[grid-geometry-manager]], [[mixing-geometry-managers-warning]]"""
            },
            {
                "slug": "grid-geometry-manager",
                "title": "The Grid Geometry Manager",
                "tags": ["layout", "grid"],
                "body": """`.grid()` places widgets in a virtual row/column table within their parent. This is the recommended default for real applications.

```python
tk.Label(root, text="Username:").grid(row=0, column=0, sticky="e", padx=5, pady=5)
tk.Entry(root).grid(row=0, column=1, padx=5, pady=5)

tk.Label(root, text="Password:").grid(row=1, column=0, sticky="e", padx=5, pady=5)
tk.Entry(root, show="*").grid(row=1, column=1, padx=5, pady=5)

tk.Button(root, text="Login").grid(row=2, column=0, columnspan=2, pady=10)
```

Key options:
- `row`, `column`: 0-indexed grid position
- `sticky`: which edges the widget "sticks" to — combos of `n`, `s`, `e`, `w` (e.g. `"nsew"` fills the cell)
- `columnspan`/`rowspan`: merge cells
- `padx`/`pady`: spacing outside the widget

Use [[grid-weights-and-resizing]] to control how extra space is distributed when the window resizes — grid alone doesn't auto-stretch anything.

See also: [[geometry-manager-overview]], [[grid-weights-and-resizing]], [[building-a-form-layout]]"""
            },
            {
                "slug": "grid-weights-and-resizing",
                "title": "Grid Weights and Window Resizing",
                "tags": ["layout", "grid", "resizing"],
                "body": """By default, `grid()` cells don't grow when the window resizes — they stay their content size, and extra space collects as dead space. `columnconfigure`/`rowconfigure` with `weight` fixes this.

```python
root.columnconfigure(0, weight=1)   # column 0 absorbs extra horizontal space
root.columnconfigure(1, weight=3)   # column 1 absorbs 3x as much as column 0
root.rowconfigure(0, weight=1)

tk.Entry(root).grid(row=0, column=1, sticky="ew")  # sticky="ew" so it actually stretches
```

Mental model: `weight` is a **ratio**, not a pixel value. `weight=1` vs `weight=1` splits space 50/50; `weight=1` vs `weight=3` splits 25/75. Weight `0` (the default) means "never grow."

Common bug: setting `weight` but forgetting `sticky="nsew"` on the widget — the cell grows but the widget stays pinned in a corner of it.

See also: [[grid-geometry-manager]], [[frame-widget]]"""
            },
            {
                "slug": "place-geometry-manager",
                "title": "The Place Geometry Manager",
                "tags": ["layout", "place"],
                "body": """`.place()` positions a widget at exact coordinates within its parent. It's the least-used manager because it doesn't adapt to resizing or content changes automatically.

```python
tk.Label(root, text="Overlay badge").place(x=10, y=10)

# relative placement (0.0–1.0), scales with parent size:
tk.Label(root, text="Centered").place(relx=0.5, rely=0.5, anchor="center")
```

Legitimate use cases:
- Overlaying a widget on top of a canvas or image (e.g. a "loading" badge on a StegoForge-style preview pane)
- Pixel-perfect splash screens
- Custom draggable elements

Avoid it for standard forms/layouts — you'll fight it on every resize. Prefer [[grid-geometry-manager]].

See also: [[geometry-manager-overview]], [[canvas-widget]]"""
            },
            {
                "slug": "mixing-geometry-managers-warning",
                "title": "Never Mix Geometry Managers In One Parent",
                "tags": ["layout", "pitfall"],
                "body": """**Rule:** within a single parent widget, use only one of `pack()`, `grid()`, or `place()`. Mixing them in the same parent causes Tkinter to freeze or deadlock the layout — this is a well-known gotcha, not a rare edge case.

```python
# ❌ BROKEN — root uses both pack and grid
tk.Label(root, text="A").pack()
tk.Label(root, text="B").grid(row=0, column=0)   # conflicts with pack in same parent
```

The fix is [[frame-widget]]: give each layout "region" its own Frame, and mix managers *across* frames freely.

```python
top_frame = tk.Frame(root)
top_frame.pack(fill="x")                 # pack used in root
tk.Label(top_frame, text="A").grid(row=0, column=0)  # grid used inside top_frame — fine
```

See also: [[frame-widget]], [[geometry-manager-overview]]"""
            },
            {
                "slug": "building-a-form-layout",
                "title": "Building a Form Layout Worked Example",
                "tags": ["layout", "grid", "worked-example"],
                "body": """A complete login-style form combining [[grid-geometry-manager]], [[grid-weights-and-resizing]], and [[frame-widget]] — the pattern you'll reuse constantly for devforge tool GUIs.

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

See also: [[grid-geometry-manager]], [[entry-widget]], [[tkinter-variables]]"""
            },
        ],
    },
    {
        "id": "03",
        "key": "core-widgets",
        "title": "Core Widgets",
        "emoji": "🧱",
        "desc": "The building blocks: Label, Button, Entry, Text, Frame, and friends.",
        "notes": [
            {
                "slug": "label-widget",
                "title": "Label Widget",
                "tags": ["widgets", "label"],
                "body": """`Label` displays text or an image — it's read-only, non-interactive.

```python
tk.Label(root, text="Status: Ready", font=("JetBrains Mono", 11), fg="#00ff9f", bg="#0d1117")
```

Common options: `text`, `textvariable` (see [[tkinter-variables]]), `font`, `fg`/`bg`, `image` (see [[image-in-labels]]), `wraplength` (wrap text at N pixels), `justify`.

For status text that changes at runtime, bind a `StringVar` via `textvariable` rather than repeatedly calling `.config(text=...)` — it's the idiomatic pattern and plays nicer with [[tkinter-variables]]-driven architecture.

See also: [[button-widget]], [[tkinter-variables]], [[styling-with-ttk]]"""
            },
            {
                "slug": "button-widget",
                "title": "Button Widget",
                "tags": ["widgets", "button"],
                "body": """`Button` triggers a callback via the `command` parameter — the primary way user actions turn into code execution.

```python
def on_scan():
    print("Scanning...")

tk.Button(root, text="Run Scan", command=on_scan, bg="#00ff9f", fg="#000000")
```

Three ways to wire a callback:
1. `command=on_scan` — no arguments passed, the common case
2. `command=lambda: on_scan(target_ip)` — pass arguments
3. Bind directly with [[binding-events]] for more control (e.g. distinguishing left/right click)

`button.config(state="disabled")` / `state="normal"` toggles it — the standard way to prevent double-submission during a long-running task (pair with [[threading-with-tkinter]]).

See also: [[binding-events]], [[tkinter-variables]], [[threading-with-tkinter]]"""
            },
            {
                "slug": "entry-widget",
                "title": "Entry Widget",
                "tags": ["widgets", "entry", "input"],
                "body": """`Entry` is a single-line text input.

```python
entry = tk.Entry(root, width=30, show="*")   # show="*" masks input — password fields
entry.insert(0, "default text")               # pre-fill
value = entry.get()                           # read current value
entry.delete(0, "end")                        # clear
```

Validation hook (useful for OSINT/cybersecurity tool inputs like IP fields):

```python
def validate_ip(new_value):
    return all(c.isdigit() or c == "." for c in new_value)

vcmd = (root.register(validate_ip), "%P")
tk.Entry(root, validate="key", validatecommand=vcmd)
```

For multi-line input use [[text-widget]] instead.

See also: [[text-widget]], [[tkinter-variables]], [[building-a-form-layout]]"""
            },
            {
                "slug": "text-widget",
                "title": "Text Widget",
                "tags": ["widgets", "text", "input"],
                "body": """`Text` is a multi-line, richly-formattable text area — think of it as `Entry`'s big sibling, used for logs, code output, or long-form input.

```python
text = tk.Text(root, height=10, width=50, bg="#0d1117", fg="#00ff9f", insertbackground="white")
text.insert("1.0", "Line one\\nLine two")   # "1.0" = line 1, char 0
content = text.get("1.0", "end")
text.delete("1.0", "end")
text.config(state="disabled")  # read-only log display — re-enable to write, then disable again
```

Index format is always `"line.char"` (1-indexed lines, 0-indexed chars), or symbolic marks like `"end"`, `"insert"` (cursor position).

For colored log output (e.g. a cyber_news-style terminal panel) use **tags**:

```python
text.tag_config("error", foreground="#ff4444")
text.insert("end", "Connection failed\\n", "error")
```

See also: [[entry-widget]], [[scrollbar-widget]], [[building-a-log-console]]"""
            },
            {
                "slug": "frame-widget",
                "title": "Frame Widget",
                "tags": ["widgets", "frame", "layout"],
                "body": """`Frame` is an invisible (by default) container used purely to group and organize other widgets — the layout equivalent of a `<div>`.

```python
sidebar = tk.Frame(root, bg="#161b22", width=200)
sidebar.pack(side="left", fill="y")

main = tk.Frame(root, bg="#0d1117")
main.pack(side="right", fill="both", expand=True)
```

Why you'll use it constantly:
- Solves [[mixing-geometry-managers-warning]] — each Frame is its own layout namespace
- Groups related widgets for show/hide (`.pack_forget()` / `.pack()` an entire frame at once)
- Building block for [[building-a-sidebar-layout]] patterns common in your devforge dark-UI tools

`LabelFrame` is a variant with a visible border and title — handy for grouping form sections ("Connection Settings", "Output Options").

See also: [[widget-hierarchy]], [[mixing-geometry-managers-warning]], [[building-a-sidebar-layout]]"""
            },
            {
                "slug": "checkbutton-and-radiobutton",
                "title": "Checkbutton and Radiobutton",
                "tags": ["widgets", "input"],
                "body": """`Checkbutton` (boolean toggle) and `Radiobutton` (mutually exclusive choice) both bind to [[tkinter-variables]] rather than being read with `.get()` directly on the widget.

```python
verbose = tk.BooleanVar(value=False)
tk.Checkbutton(root, text="Verbose output", variable=verbose).pack()

mode = tk.StringVar(value="tcp")
tk.Radiobutton(root, text="TCP", variable=mode, value="tcp").pack()
tk.Radiobutton(root, text="UDP", variable=mode, value="udp").pack()

# later:
if verbose.get():
    ...
print(mode.get())  # "tcp" or "udp"
```

All `Radiobutton`s sharing the same `variable` are automatically mutually exclusive — no manual "uncheck the others" logic needed.

See also: [[tkinter-variables]], [[button-widget]]"""
            },
            {
                "slug": "listbox-and-combobox",
                "title": "Listbox and Combobox",
                "tags": ["widgets", "input", "ttk"],
                "body": """`Listbox` (classic tk) shows a scrollable list of selectable items; `ttk.Combobox` is a dropdown select — both common in tool GUIs for picking targets, interfaces, or presets.

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

See also: [[ttk-themed-widgets]], [[scrollbar-widget]]"""
            },
            {
                "slug": "scrollbar-widget",
                "title": "Scrollbar Widget",
                "tags": ["widgets", "scrollbar"],
                "body": """`Scrollbar` doesn't scroll anything by itself — it must be explicitly linked to a scrollable widget ([[text-widget]], `Listbox`, `Canvas`) via `.config(command=...)` and `.config(yscrollcommand=...)`. This two-way wiring trips up almost everyone the first time.

```python
text = tk.Text(root, wrap="none")
scroll_y = tk.Scrollbar(root, orient="vertical", command=text.yview)
text.config(yscrollcommand=scroll_y.set)

text.grid(row=0, column=0, sticky="nsew")
scroll_y.grid(row=0, column=1, sticky="ns")
```

The pattern is symmetric: the scrollbar tells the widget where to scroll (`command`), and the widget tells the scrollbar where it currently is (`yscrollcommand`). Skip either half and you get a scrollbar that either doesn't move the content, or doesn't reflect the current position.

See also: [[text-widget]], [[canvas-widget]], [[building-a-log-console]]"""
            },
            {
                "slug": "canvas-widget",
                "title": "Canvas Widget",
                "tags": ["widgets", "canvas", "drawing"],
                "body": """`Canvas` is a free-form drawing surface — lines, shapes, text, and images at arbitrary coordinates. It's what you'd reach for to build custom visualizations (relevant given your black-hole-simulator and PixelArt-generator background).

```python
canvas = tk.Canvas(root, width=400, height=300, bg="#0d1117")
canvas.pack()

canvas.create_line(0, 0, 400, 300, fill="#00ff9f", width=2)
canvas.create_rectangle(50, 50, 150, 100, outline="#00ff9f", fill="")
oval_id = canvas.create_oval(200, 150, 260, 210, fill="cyan")

canvas.move(oval_id, 10, 0)          # shift the oval
canvas.itemconfig(oval_id, fill="red")  # restyle it
```

Every `create_*` call returns an ID you use later to move, restyle, or delete that specific item — Canvas objects are addressable, not just drawn-and-forgotten.

See also: [[place-geometry-manager]], [[image-in-labels]]"""
            },
            {
                "slug": "image-in-labels",
                "title": "Displaying Images",
                "tags": ["widgets", "images"],
                "body": """Tkinter's built-in `PhotoImage` only supports GIF/PGM/PPM/PNG (PNG support depends on Tcl/Tk version). For JPEG or reliable cross-format support, use **Pillow**.

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

See also: [[label-widget]], [[canvas-widget]]"""
            },
            {
                "slug": "building-a-sidebar-layout",
                "title": "Building a Sidebar Layout Worked Example",
                "tags": ["widgets", "layout", "worked-example"],
                "body": """A dark-themed sidebar + main-panel shell — the skeleton you'll reuse for most devforge tool GUIs (PacketForge, StegoForge-style layouts). Combines [[frame-widget]], [[pack-geometry-manager]], and [[dark-mode-color-palette]].

```python
import tkinter as tk

BG_DARK, BG_PANEL, FG_GREEN = "#0d1117", "#161b22", "#00ff9f"

root = tk.Tk()
root.title("Tool Shell")
root.geometry("700x450")
root.configure(bg=BG_DARK)

# sidebar — fixed width, docked left
sidebar = tk.Frame(root, bg=BG_PANEL, width=180)
sidebar.pack(side="left", fill="y")
sidebar.pack_propagate(False)  # stop children from shrinking the frame to fit

for label_text in ["Dashboard", "Scan", "Reports", "Settings"]:
    tk.Label(sidebar, text=label_text, bg=BG_PANEL, fg=FG_GREEN,
              anchor="w", padx=15, pady=10, font=("JetBrains Mono", 10)).pack(fill="x")

# main content — expands to fill remaining space
main = tk.Frame(root, bg=BG_DARK)
main.pack(side="right", fill="both", expand=True)
tk.Label(main, text="Main Content Area", bg=BG_DARK, fg=FG_GREEN).pack(padx=20, pady=20)

root.mainloop()
```

`pack_propagate(False)` is the key detail: without it, a Frame shrinks to fit its children, undermining a fixed-width sidebar the moment content changes.

See also: [[frame-widget]], [[dark-mode-color-palette]], [[building-a-log-console]]"""
            },
            {
                "slug": "building-a-log-console",
                "title": "Building a Log Console Worked Example",
                "tags": ["widgets", "text", "worked-example"],
                "body": """A scrollable, color-tagged log console — the pattern behind a cyber_news-style terminal panel or live scan output. Combines [[text-widget]], [[scrollbar-widget]], and tag-based coloring.

```python
import tkinter as tk

BG_DARK = "#0d1117"

root = tk.Tk()
root.title("Log Console")
root.configure(bg=BG_DARK)

frame = tk.Frame(root)
frame.pack(fill="both", expand=True, padx=10, pady=10)
frame.rowconfigure(0, weight=1)
frame.columnconfigure(0, weight=1)

log = tk.Text(frame, bg=BG_DARK, fg="#c9d1d9", insertbackground="white",
               font=("JetBrains Mono", 10), state="disabled", wrap="word")
log.grid(row=0, column=0, sticky="nsew")

scroll = tk.Scrollbar(frame, orient="vertical", command=log.yview)
scroll.grid(row=0, column=1, sticky="ns")
log.config(yscrollcommand=scroll.set)

log.tag_config("info", foreground="#39d5ff")
log.tag_config("success", foreground="#00ff9f")
log.tag_config("error", foreground="#ff4444")

def write_log(message, level="info"):
    log.config(state="normal")          # briefly unlock to write
    log.insert("end", message + "\\n", level)
    log.see("end")                       # auto-scroll to newest line
    log.config(state="disabled")         # relock — read-only again

write_log("Initializing scanner...", "info")
write_log("Target acquired: 192.168.1.1", "info")
write_log("Scan complete: 3 open ports", "success")

root.mainloop()
```

`log.see("end")` is what makes it feel like a live terminal — without it, new lines append below the visible area and the user has to scroll manually to see them.

See also: [[text-widget]], [[scrollbar-widget]], [[threading-with-tkinter]]"""
            },
        ],
    },
    {
        "id": "04",
        "key": "events-and-binding",
        "title": "Events and Binding",
        "emoji": "⚡",
        "desc": "Responding to user input beyond simple button clicks — keyboard, mouse, and custom events.",
        "notes": [
            {
                "slug": "binding-events",
                "title": "Binding Events With bind",
                "tags": ["events", "bind"],
                "body": """`.bind(event, callback)` attaches a handler to a widget for a specific event string. This is more general than `Button`'s `command` — it works on *any* widget for *any* event type.

```python
def on_enter_key(event):
    print("Enter pressed, entry contains:", event.widget.get())

entry = tk.Entry(root)
entry.bind("<Return>", on_enter_key)

root.bind("<Escape>", lambda event: root.destroy())  # bind at window level
```

The callback always receives an `event` object with useful attributes: `event.widget`, `event.x`/`event.y` (for mouse events), `event.keysym` (for key events), `event.char`.

Binding scope matters: `.bind()` on a specific widget fires only for that widget; `.bind_all()` fires globally regardless of focus. Prefer scoped binds unless you specifically need global hotkeys.

See also: [[keyboard-events]], [[mouse-events]], [[event-object-attributes]]"""
            },
            {
                "slug": "event-object-attributes",
                "title": "The Event Object",
                "tags": ["events", "reference"],
                "body": """Every bound callback receives one `event` argument carrying details about what happened. Useful attributes by event category:

| Attribute | Meaning | Relevant for |
|---|---|---|
| `event.widget` | The widget that triggered the event | All events |
| `event.x`, `event.y` | Mouse position relative to widget | Mouse events |
| `event.x_root`, `event.y_root` | Mouse position relative to screen | Mouse events |
| `event.keysym` | Symbolic key name (`"Return"`, `"a"`, `"Escape"`) | Key events |
| `event.char` | The actual character typed (empty for non-printable) | Key events |
| `event.num` | Which mouse button (1=left, 2=middle, 3=right) | Click events |

```python
def log_click(event):
    print(f"Clicked {event.widget} at ({event.x}, {event.y}) with button {event.num}")

widget.bind("<Button-1>", log_click)
```

See also: [[binding-events]], [[keyboard-events]], [[mouse-events]]"""
            },
            {
                "slug": "keyboard-events",
                "title": "Keyboard Events",
                "tags": ["events", "keyboard"],
                "body": """Keyboard event strings follow Tk's `<Modifier-Key>` naming convention.

```python
root.bind("<Return>", handler)          # Enter key
root.bind("<KeyPress>", handler)        # any key down
root.bind("<KeyRelease>", handler)      # any key up
root.bind("<Control-s>", save_handler)  # Ctrl+S — common for "save" shortcuts
root.bind("<Control-Shift-N>", handler) # multi-modifier combo
entry.bind("<Key>", live_validate)      # fires on every keystroke, before it lands
```

For live input validation (e.g. rejecting non-hex characters as they're typed into a hash-input field), `<KeyRelease>` is usually more reliable than `<Key>` since it fires *after* the character is inserted, so `entry.get()` reflects the new value.

See also: [[binding-events]], [[event-object-attributes]], [[entry-widget]]"""
            },
            {
                "slug": "mouse-events",
                "title": "Mouse Events",
                "tags": ["events", "mouse"],
                "body": """```python
widget.bind("<Button-1>", handler)        # left click
widget.bind("<Button-3>", handler)        # right click — common for context menus
widget.bind("<Double-Button-1>", handler) # double-click
widget.bind("<B1-Motion>", handler)       # dragging with left button held
widget.bind("<Enter>", handler)           # mouse enters widget bounds (hover start)
widget.bind("<Leave>", handler)           # mouse leaves widget bounds (hover end)
widget.bind("<MouseWheel>", handler)      # scroll wheel (delta sign/magnitude is platform-dependent)
```

Right-click context menus are a common pattern combining `<Button-3>` with a `Menu` widget's `.tk_popup(event.x_root, event.y_root)`.

`<Enter>`/`<Leave>` are the basis for hover-highlight effects — pair with `.config(bg=...)` to build a lightweight custom-styled button before reaching for full [[styling-with-ttk]].

See also: [[binding-events]], [[event-object-attributes]]"""
            },
            {
                "slug": "the-after-method",
                "title": "The after Method for Timers and Non Blocking Delays",
                "tags": ["events", "timing", "concurrency"],
                "body": """`.after(ms, callback)` schedules `callback` to run once, `ms` milliseconds from now, **without blocking the event loop**. It's Tkinter's built-in alternative to `time.sleep()` inside a callback.

```python
def tick():
    label.config(text=f"Elapsed: {count[0]}s")
    count[0] += 1
    root.after(1000, tick)   # reschedule itself — a self-driving timer loop

count = [0]
root.after(1000, tick)
```

Common uses:
- Polling a queue for results from a background thread (see [[threading-with-tkinter]])
- Debouncing rapid events (e.g. search-as-you-type — cancel and reschedule on each keystroke via `.after_cancel(id)`)
- Simple animations or auto-refreshing status displays

`.after_cancel(after_id)` cancels a pending scheduled call — save the ID returned by `.after()` if you'll need to cancel it.

See also: [[the-event-loop]], [[threading-with-tkinter]]"""
            },
        ],
    },
    {
        "id": "05",
        "key": "variables-and-state",
        "title": "Variables and State",
        "emoji": "🔗",
        "desc": "Tkinter's built-in reactive-ish variable types — the closest thing to two-way data binding it has.",
        "notes": [
            {
                "slug": "tkinter-variables",
                "title": "Tkinter Variable Types Overview",
                "tags": ["state", "variables"],
                "body": """Tkinter provides four variable wrapper classes that link Python state directly to widgets: `StringVar`, `IntVar`, `DoubleVar`, `BooleanVar`. They're the closest Tkinter gets to reactive/two-way data binding.

```python
name = tk.StringVar(value="")
count = tk.IntVar(value=0)
ratio = tk.DoubleVar(value=0.0)
enabled = tk.BooleanVar(value=True)

entry = tk.Entry(root, textvariable=name)  # typing updates `name` automatically
label = tk.Label(root, textvariable=name)  # label text updates automatically too
```

Why use these instead of `.get()`/`.insert()` on the widget directly?
- One variable can drive **multiple widgets** in sync (an Entry and a Label both showing the same value)
- They support [[variable-tracing]] — running a callback whenever the value changes
- They decouple your app logic from widget internals — closer to the MVC pattern in [[mvc-lite-pattern]]

See also: [[variable-tracing]], [[entry-widget]], [[mvc-lite-pattern]]"""
            },
            {
                "slug": "variable-tracing",
                "title": "Variable Tracing",
                "tags": ["state", "variables", "callbacks"],
                "body": """`.trace_add(mode, callback)` runs a callback automatically whenever a Tkinter variable changes — this is how you build reactive UI without manually wiring every widget update.

```python
search_term = tk.StringVar()

def on_search_change(*args):
    query = search_term.get()
    results_label.config(text=f"Searching for: {query}")

search_term.trace_add("write", on_search_change)
tk.Entry(root, textvariable=search_term).pack()
```

Trace modes: `"write"` (value changed — the common case), `"read"` (value accessed), `"unset"` (variable deleted).

The callback signature is always `(var_name, index, mode)` regardless of what triggered it — use `*args` to absorb these since you rarely need them; call `.get()` on the variable itself instead.

This pattern is exactly how a live search-filter or password-strength meter gets built without a Button in the loop at all.

See also: [[tkinter-variables]], [[the-after-method]]"""
            },
        ],
    },
    {
        "id": "06",
        "key": "dialogs-menus-windows",
        "title": "Dialogs Menus and Windows",
        "emoji": "🪟",
        "desc": "Multi-window applications, native dialogs, and menu bars.",
        "notes": [
            {
                "slug": "toplevel-windows",
                "title": "Toplevel Windows",
                "tags": ["windows", "toplevel"],
                "body": """`Toplevel` creates an additional window beyond the [[root-window]] — a settings dialog, an about box, a secondary tool panel. Never call `tk.Tk()` a second time; always use `Toplevel`.

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

See also: [[root-window]], [[messagebox-dialogs]]"""
            },
            {
                "slug": "messagebox-dialogs",
                "title": "Messagebox Dialogs",
                "tags": ["windows", "dialogs"],
                "body": """`tkinter.messagebox` provides native OS-styled popup dialogs for alerts and simple confirmations — no need to hand-build a Toplevel for these common cases.

```python
from tkinter import messagebox

messagebox.showinfo("Scan Complete", "Found 12 open ports.")
messagebox.showwarning("Weak Signal", "Connection may be unstable.")
messagebox.showerror("Error", "Failed to connect to target.")

if messagebox.askyesno("Confirm Delete", "Delete this vault entry?"):
    delete_entry()

response = messagebox.askokcancel("Proceed?", "This will overwrite existing data.")
```

All of these are **blocking** — they pause execution (but not the whole event loop) until the user responds, and return the user's choice directly, which is why `askyesno`/`askokcancel` slot straight into an `if`.

See also: [[toplevel-windows]], [[filedialog-usage]]"""
            },
            {
                "slug": "filedialog-usage",
                "title": "File Dialogs",
                "tags": ["windows", "dialogs", "files"],
                "body": """`tkinter.filedialog` provides native open/save file pickers — essential for any tool that reads/writes files (directly relevant to StegoForge, CryptForge-style file-based tools).

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

See also: [[messagebox-dialogs]], [[entry-widget]]"""
            },
            {
                "slug": "menu-widget",
                "title": "Menu Bars and Context Menus",
                "tags": ["windows", "menu"],
                "body": """`Menu` builds both top-level menu bars (File/Edit/Help) and right-click context menus.

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

See also: [[binding-events]], [[toplevel-windows]]"""
            },
        ],
    },
    {
        "id": "07",
        "key": "styling-and-themes",
        "title": "Styling and Themes",
        "emoji": "🎨",
        "desc": "Making Tkinter look intentional instead of like 1998 — ttk, fonts, colors, and dark-mode patterns matching your devforge aesthetic.",
        "notes": [
            {
                "slug": "ttk-themed-widgets",
                "title": "ttk Themed Widgets",
                "tags": ["styling", "ttk"],
                "body": """`ttk` (Tk Themed widgets) is a parallel widget set that respects OS/theme styling and looks dramatically less dated than classic `tk` widgets. Prefer `ttk` versions whenever one exists.

```python
from tkinter import ttk

ttk.Button(root, text="Click me").pack()
ttk.Entry(root).pack()
ttk.Label(root, text="Styled label").pack()
ttk.Combobox(root, values=["A", "B"]).pack()   # no plain-tk equivalent
ttk.Progressbar(root, mode="determinate").pack()  # no plain-tk equivalent
ttk.Treeview(root)  # table/tree view — no plain-tk equivalent
```

Important gotcha: `ttk` widgets **don't accept `bg`/`fg` directly** the way classic `tk` widgets do — you style them through [[styling-with-ttk]]'s `Style` object instead. Mixing `tk.Button(bg=...)` and `ttk.Button` styling approaches in one app is a common source of "why won't this color apply" confusion.

See also: [[styling-with-ttk]], [[button-widget]], [[listbox-and-combobox]]"""
            },
            {
                "slug": "styling-with-ttk",
                "title": "Styling ttk Widgets With Style",
                "tags": ["styling", "ttk", "theme"],
                "body": """`ttk.Style()` is how you actually recolor/restyle `ttk` widgets — direct `bg=`/`fg=` kwargs are ignored or limited on most ttk widgets.

```python
from tkinter import ttk

style = ttk.Style()
style.theme_use("clam")   # 'clam' themes best for custom colors; try 'alt', 'default', 'classic' too

style.configure(
    "Dark.TButton",
    background="#0d1117",
    foreground="#00ff9f",
    font=("JetBrains Mono", 10),
    borderwidth=0,
)
style.map("Dark.TButton", background=[("active", "#161b22")])  # hover/pressed state

ttk.Button(root, text="Scan", style="Dark.TButton").pack()
```

Pattern: define a **named style** (`"Dark.TButton"`) rather than restyling the base `"TButton"` globally — this lets you have both a normal button and a "danger" red-styled button coexisting.

`style.map()` handles state-dependent styling (`active` = hovered/pressed, `disabled`) — this is the ttk equivalent of CSS `:hover`.

See also: [[ttk-themed-widgets]], [[dark-mode-color-palette]]"""
            },
            {
                "slug": "dark-mode-color-palette",
                "title": "Building a Dark Terminal Aesthetic",
                "tags": ["styling", "theme", "dark-mode"],
                "body": """A reusable color/font constants module matching the phosphor-green/cyan cyberpunk aesthetic across your devforge tools (StegoForge, PacketForge, etc.) — define once, import everywhere.

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

See also: [[styling-with-ttk]], [[ttk-themed-widgets]]"""
            },
            {
                "slug": "custom-fonts",
                "title": "Working With Fonts",
                "tags": ["styling", "fonts"],
                "body": """Fonts can be set as a simple tuple or via the `tkinter.font` module for more control (measuring text, dynamic resizing).

```python
import tkinter as tk
from tkinter import font

label = tk.Label(root, text="Hello", font=("JetBrains Mono", 12, "bold"))

# tkinter.font.Font object — needed for dynamic updates or measuring
title_font = font.Font(family="JetBrains Mono", size=16, weight="bold")
label2 = tk.Label(root, text="Title", font=title_font)
title_font.configure(size=20)  # updates label2 automatically — Font objects are live references
```

Availability caveat: a font name is only usable if it's actually installed on the user's system — Tkinter silently falls back to a default font rather than erroring, so always test on a machine where your chosen font (e.g. JetBrains Mono) isn't pre-installed to see the fallback behavior.

See also: [[dark-mode-color-palette]], [[label-widget]]"""
            },
        ],
    },
    {
        "id": "08",
        "key": "architecture-patterns",
        "title": "Architecture Patterns",
        "emoji": "🏗️",
        "desc": "Structuring real applications: class-based apps, MVC-lite, threading, and packaging for distribution.",
        "notes": [
            {
                "slug": "class-based-tkinter-apps",
                "title": "Class Based Application Structure",
                "tags": ["architecture", "oop"],
                "body": """Beyond trivial scripts, wrap the app in a class inheriting from `tk.Tk` (or composing one) — this is the direct Tkinter analog to the `QMainWindow` subclassing pattern you already use in PySide6.

```python
import tkinter as tk

class ScannerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Port Scanner")
        self.geometry("500x400")
        self._build_widgets()

    def _build_widgets(self):
        self.target_var = tk.StringVar()
        tk.Entry(self, textvariable=self.target_var).pack(pady=10)
        tk.Button(self, text="Scan", command=self._on_scan).pack()
        self.output = tk.Text(self, height=15)
        self.output.pack(fill="both", expand=True)

    def _on_scan(self):
        target = self.target_var.get()
        self.output.insert("end", f"Scanning {target}...\\n")

if __name__ == "__main__":
    app = ScannerApp()
    app.mainloop()
```

Benefits over a flat script: widgets become `self.` attributes accessible from any method (no global variables), the app is trivially testable/importable, and it scales cleanly into [[mvc-lite-pattern]] as complexity grows.

See also: [[mvc-lite-pattern]], [[multi-file-tkinter-projects]]"""
            },
            {
                "slug": "mvc-lite-pattern",
                "title": "MVC Lite Pattern for Tkinter",
                "tags": ["architecture", "mvc"],
                "body": """Full MVC is often overkill for a Tkinter tool, but a **light separation** between data/logic and widgets pays off fast as an app grows past ~200 lines — the same instinct behind your file threat-analysis engine's separation of scoring logic from CLI presentation.

```python
# model.py — no tkinter imports at all
class ScanModel:
    def __init__(self):
        self.results = []

    def scan(self, target: str) -> list[int]:
        self.results = [22, 80, 443]  # placeholder for real logic
        return self.results


# view.py — widgets only, no business logic
import tkinter as tk

class ScanView(tk.Frame):
    def __init__(self, master, on_scan_click):
        super().__init__(master)
        self.target_var = tk.StringVar()
        tk.Entry(self, textvariable=self.target_var).pack()
        tk.Button(self, text="Scan", command=on_scan_click).pack()
        self.output = tk.Listbox(self)
        self.output.pack()

    def show_results(self, ports: list[int]):
        self.output.delete(0, "end")
        for p in ports:
            self.output.insert("end", f"Port {p} open")


# controller — wires model to view
class ScanController:
    def __init__(self, root):
        self.model = ScanModel()
        self.view = ScanView(root, on_scan_click=self.handle_scan)
        self.view.pack()

    def handle_scan(self):
        target = self.view.target_var.get()
        results = self.model.scan(target)
        self.view.show_results(results)
```

Payoff: `ScanModel` is unit-testable with zero GUI dependency — you can `pytest` your scanning logic exactly like your password manager's crypto stack, independent of Tkinter entirely.

See also: [[class-based-tkinter-apps]], [[multi-file-tkinter-projects]]"""
            },
            {
                "slug": "threading-with-tkinter",
                "title": "Threading With Tkinter",
                "tags": ["architecture", "concurrency", "threading"],
                "body": """Tkinter is **not thread-safe** — you must never touch a widget from any thread other than the main thread. But long tasks (network scans, file hashing) can't block [[the-event-loop]] either. The standard fix: run the work in a background thread, and pass results back through a `queue.Queue`, polled via [[the-after-method]].

```python
import threading
import queue
import tkinter as tk

class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.result_queue = queue.Queue()
        tk.Button(self, text="Start Scan", command=self.start_scan).pack()
        self.label = tk.Label(self, text="Idle")
        self.label.pack()
        self.after(100, self.poll_queue)

    def start_scan(self):
        self.label.config(text="Scanning...")
        threading.Thread(target=self.worker, daemon=True).start()

    def worker(self):
        # runs in background thread — NEVER touch self.label here directly
        import time
        time.sleep(3)
        self.result_queue.put("Scan complete: 3 hosts found")

    def poll_queue(self):
        try:
            message = self.result_queue.get_nowait()
            self.label.config(text=message)   # safe — this runs on the main thread
        except queue.Empty:
            pass
        self.after(100, self.poll_queue)   # keep polling
```

`daemon=True` on the thread ensures it won't block app exit if it's still running when the window closes. This exact pattern is what you'll want for any devforge GUI wrapping a slow CLI tool (TraceForge, DigitForge) behind a responsive UI.

See also: [[the-after-method]], [[the-event-loop]], [[button-widget]]"""
            },
            {
                "slug": "multi-file-tkinter-projects",
                "title": "Structuring a Multi File Tkinter Project",
                "tags": ["architecture", "project-structure"],
                "body": """A conventional layout for a Tkinter app beyond single-file scripts, mirroring how your devforge PySide6 projects are already organized:

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

See also: [[mvc-lite-pattern]], [[class-based-tkinter-apps]]"""
            },
            {
                "slug": "packaging-with-pyinstaller",
                "title": "Packaging a Tkinter App With PyInstaller",
                "tags": ["architecture", "packaging", "distribution"],
                "body": """`PyInstaller` bundles a Tkinter app plus the Python interpreter into a single distributable executable — no "install Python first" requirement for end users.

```bash
pip install pyinstaller

# one-file executable, no console window (GUI app):
pyinstaller --onefile --windowed --name MyApp main.py

# with an icon and bundled assets:
pyinstaller --onefile --windowed --icon=assets/icon.ico \\
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

See also: [[multi-file-tkinter-projects]], [[image-in-labels]]"""
            },
        ],
    },
]

# ---------------------------------------------------------------------------
# TEMPLATES
# ---------------------------------------------------------------------------

def note_frontmatter(domain, note):
    tags = " ".join(f"#{t}" for t in note["tags"])
    return f"""---
title: "{note['title']}"
domain: "{domain['id']}-{domain['key']}"
tags: [{', '.join(note['tags'])}]
created: {TODAY}
type: atomic-note
---

# {note['title']}

{tags}

"""

def note_footer(domain):
    return f"""

---
📍 Part of [[{domain_moc_filename(domain)}|{domain['title']} MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
"""

def domain_moc_filename(domain):
    return f"{domain['id']} {domain['title']} MOC"

def build_domain_moc(domain):
    lines = [
        "---",
        f'title: "{domain["title"]} MOC"',
        "type: moc",
        f"created: {TODAY}",
        "---",
        "",
        f"# {domain['emoji']} {domain['id']} — {domain['title']}",
        "",
        f"> {domain['desc']}",
        "",
        "## Notes in this domain",
        "",
    ]
    for note in domain["notes"]:
        lines.append(f"- [[{note['slug']}|{note['title']}]]")
    lines.append("")
    lines.append("---")
    lines.append("🗺️ [[00 Tkinter MOC|← Back to Vault Home]]")
    lines.append("")
    return "\n".join(lines)

def build_master_moc(domains):
    lines = [
        "---",
        'title: "Tkinter MOC"',
        "type: moc",
        f"created: {TODAY}",
        "---",
        "",
        "# 🐍 Tkinter — Second Brain",
        "",
        "> Map of Content for the full Tkinter learning vault. MVP scope: GUI fundamentals, weighted toward widgets and layout. Extend by adding domains to `generate_vault.py` and re-running.",
        "",
        "## Progress Tracker",
        "",
        "| Domain | Status |",
        "|---|---|",
    ]
    for d in domains:
        lines.append(f"| [[{domain_moc_filename(d)}|{d['emoji']} {d['title']}]] | ⬜ Not started |")
    lines.append("")
    lines.append("## Domains")
    lines.append("")
    for d in domains:
        lines.append(f"### {d['emoji']} [[{domain_moc_filename(d)}|{d['id']} — {d['title']}]]")
        lines.append(f"{d['desc']}")
        lines.append("")
        for note in d["notes"]:
            lines.append(f"- [[{note['slug']}|{note['title']}]]")
        lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## How to use this vault")
    lines.append("")
    lines.append("1. Start at a domain MOC, read notes in order — each links forward via `See also:`.")
    lines.append("2. Use Obsidian's **Graph View** to see the whole domain as a connected web.")
    lines.append("3. This is an MVP (~45 notes, fundamentals-weighted). Planned Phase 2 domains: Canvas deep-dive, custom widgets, `asyncio` integration, testing GUIs, advanced Treeview.")
    lines.append("4. Perfectionism note to self: **ship the MVP, use it in a real devforge tool, then expand.** Don't let this vault become another mid-build stall.")
    lines.append("")
    return "\n".join(lines)

def build_readme(domains, note_count):
    lines = [
        "# Tkinter Second Brain — Obsidian Vault",
        "",
        f"Generated {TODAY} · {len(domains)} domains · {note_count} atomic notes",
        "",
        "## Setup",
        "",
        "1. Open Obsidian → **Open folder as vault** → select this directory.",
        '2. Start at `00 Tkinter MOC.md`.',
        "3. Enable **Graph View** (left ribbon) to see the note web.",
        "",
        "## Structure",
        "",
        "```",
        "TkinterVault/",
        "├── 00 Tkinter MOC.md          ← start here",
        "├── 01-core-concepts/",
        "│   ├── 01 Core Concepts MOC.md",
        "│   └── *.md  (atomic notes)",
        "├── 02-geometry-managers/",
        "├── 03-core-widgets/",
        "├── 04-events-and-binding/",
        "├── 05-variables-and-state/",
        "├── 06-dialogs-menus-windows/",
        "├── 07-styling-and-themes/",
        "└── 08-architecture-patterns/",
        "```",
        "",
        "## Regenerating / extending",
        "",
        "This vault is produced by `generate_vault.py` (pure stdlib, no dependencies).",
        "To add notes: edit the `DOMAINS` list in the script and re-run — it's idempotent",
        "and will overwrite existing generated files cleanly.",
        "",
        "```bash",
        "python generate_vault.py --out ./TkinterVault",
        "python generate_vault.py --validate   # check all [[wikilinks]] resolve to real notes",
        "```",
        "",
        "## Phase 2 (not yet built)",
        "",
        "- Canvas deep-dive (animations, custom widget drawing)",
        "- Custom widget subclassing",
        "- `asyncio` + Tkinter integration patterns",
        "- Testing Tkinter GUIs (pytest + widget interaction)",
        "- Advanced Treeview (sortable columns, embedded data tables)",
        "- Drag-and-drop",
        "",
    ]
    return "\n".join(lines)

# ---------------------------------------------------------------------------
# GENERATION
# ---------------------------------------------------------------------------

def slugify_dirname(domain):
    return f"{domain['id']}-{domain['key']}"

def generate(out_dir: Path):
    out_dir.mkdir(parents=True, exist_ok=True)

    note_count = 0
    slug_to_domain = {}

    for domain in DOMAINS:
        domain_dir = out_dir / slugify_dirname(domain)
        domain_dir.mkdir(parents=True, exist_ok=True)

        # domain MOC
        moc_path = domain_dir / f"{domain_moc_filename(domain)}.md"
        moc_path.write_text(build_domain_moc(domain), encoding="utf-8")

        # notes
        for note in domain["notes"]:
            slug_to_domain[note["slug"]] = domain
            note_path = domain_dir / f"{note['slug']}.md"
            content = note_frontmatter(domain, note) + note["body"] + note_footer(domain)
            note_path.write_text(content, encoding="utf-8")
            note_count += 1

    # master MOC at root
    master_path = out_dir / "00 Tkinter MOC.md"
    master_path.write_text(build_master_moc(DOMAINS), encoding="utf-8")

    # README
    readme_path = out_dir / "README.md"
    readme_path.write_text(build_readme(DOMAINS, note_count), encoding="utf-8")

    return note_count, slug_to_domain

def validate(out_dir: Path, slug_to_domain: dict):
    """Check every [[wikilink]] in generated notes points to a real note slug or a known MOC."""
    known_slugs = set(slug_to_domain.keys())
    known_mocs = {domain_moc_filename(d) for d in DOMAINS} | {"Tkinter MOC", "00 Tkinter MOC"}

    broken = []
    link_pattern = re.compile(r"\[\[([^\]|]+)(?:\|[^\]]+)?\]\]")

    for md_file in out_dir.rglob("*.md"):
        if md_file.name == "README.md":
            continue
        text = md_file.read_text(encoding="utf-8")
        for match in link_pattern.finditer(text):
            target = match.group(1).strip()
            if target in known_slugs or target in known_mocs:
                continue
            broken.append((md_file.relative_to(out_dir), target))

    if broken:
        print(f"\n❌ {len(broken)} broken wikilink(s) found:")
        for file, target in broken:
            print(f"   {file} -> [[{target}]]")
        return False
    else:
        print(f"\n✅ All wikilinks resolve correctly across {len(known_slugs)} notes.")
        return True

def main():
    parser = argparse.ArgumentParser(description="Generate the Tkinter Obsidian vault")
    parser.add_argument("--out", default="./TkinterVault", help="Output directory")
    parser.add_argument("--validate", action="store_true", help="Validate wikilinks after generation")
    args = parser.parse_args()

    out_dir = Path(args.out).resolve()
    note_count, slug_to_domain = generate(out_dir)

    print(f"✅ Generated {note_count} atomic notes across {len(DOMAINS)} domains")
    print(f"📁 Output: {out_dir}")

    if args.validate:
        ok = validate(out_dir, slug_to_domain)
        sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()
