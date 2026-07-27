---
title: "Tkinter MOC"
type: moc
created: 2026-07-27
---

# 🐍 Tkinter — Second Brain

> Map of Content for the full Tkinter learning vault. MVP scope: GUI fundamentals, weighted toward widgets and layout. Extend by adding domains to `generate_vault.py` and re-running.

## Progress Tracker

| Domain | Status |
|---|---|
| [[01 Core Concepts MOC|🧠 Core Concepts]] | ⬜ Not started |
| [[02 Geometry Managers MOC|📐 Geometry Managers]] | ⬜ Not started |
| [[03 Core Widgets MOC|🧱 Core Widgets]] | ⬜ Not started |
| [[04 Events and Binding MOC|⚡ Events and Binding]] | ⬜ Not started |
| [[05 Variables and State MOC|🔗 Variables and State]] | ⬜ Not started |
| [[06 Dialogs Menus and Windows MOC|🪟 Dialogs Menus and Windows]] | ⬜ Not started |
| [[07 Styling and Themes MOC|🎨 Styling and Themes]] | ⬜ Not started |
| [[08 Architecture Patterns MOC|🏗️ Architecture Patterns]] | ⬜ Not started |

## Domains

### 🧠 [[01 Core Concepts MOC|01 — Core Concepts]]
The mental model of Tkinter: what a GUI app actually *is* at runtime.

- [[what-is-tkinter|What Is Tkinter]]
- [[tkinter-vs-pyqt6|Tkinter vs PyQt6 PySide6]]
- [[root-window|The Root Window]]
- [[the-event-loop|The Event Loop]]
- [[widget-hierarchy|Widget Hierarchy and Parent Child]]
- [[tkinter-import-conventions|Import Conventions]]

### 📐 [[02 Geometry Managers MOC|02 — Geometry Managers]]
How widgets get placed on screen — pack, grid, and place. The #1 source of layout confusion; worth mastering deeply.

- [[geometry-manager-overview|Geometry Manager Overview]]
- [[pack-geometry-manager|The Pack Geometry Manager]]
- [[grid-geometry-manager|The Grid Geometry Manager]]
- [[grid-weights-and-resizing|Grid Weights and Window Resizing]]
- [[place-geometry-manager|The Place Geometry Manager]]
- [[mixing-geometry-managers-warning|Never Mix Geometry Managers In One Parent]]
- [[building-a-form-layout|Building a Form Layout Worked Example]]

### 🧱 [[03 Core Widgets MOC|03 — Core Widgets]]
The building blocks: Label, Button, Entry, Text, Frame, and friends.

- [[label-widget|Label Widget]]
- [[button-widget|Button Widget]]
- [[entry-widget|Entry Widget]]
- [[text-widget|Text Widget]]
- [[frame-widget|Frame Widget]]
- [[checkbutton-and-radiobutton|Checkbutton and Radiobutton]]
- [[listbox-and-combobox|Listbox and Combobox]]
- [[scrollbar-widget|Scrollbar Widget]]
- [[canvas-widget|Canvas Widget]]
- [[image-in-labels|Displaying Images]]
- [[building-a-sidebar-layout|Building a Sidebar Layout Worked Example]]
- [[building-a-log-console|Building a Log Console Worked Example]]

### ⚡ [[04 Events and Binding MOC|04 — Events and Binding]]
Responding to user input beyond simple button clicks — keyboard, mouse, and custom events.

- [[binding-events|Binding Events With bind]]
- [[event-object-attributes|The Event Object]]
- [[keyboard-events|Keyboard Events]]
- [[mouse-events|Mouse Events]]
- [[the-after-method|The after Method for Timers and Non Blocking Delays]]

### 🔗 [[05 Variables and State MOC|05 — Variables and State]]
Tkinter's built-in reactive-ish variable types — the closest thing to two-way data binding it has.

- [[tkinter-variables|Tkinter Variable Types Overview]]
- [[variable-tracing|Variable Tracing]]

### 🪟 [[06 Dialogs Menus and Windows MOC|06 — Dialogs Menus and Windows]]
Multi-window applications, native dialogs, and menu bars.

- [[toplevel-windows|Toplevel Windows]]
- [[messagebox-dialogs|Messagebox Dialogs]]
- [[filedialog-usage|File Dialogs]]
- [[menu-widget|Menu Bars and Context Menus]]

### 🎨 [[07 Styling and Themes MOC|07 — Styling and Themes]]
Making Tkinter look intentional instead of like 1998 — ttk, fonts, colors, and dark-mode patterns matching your devforge aesthetic.

- [[ttk-themed-widgets|ttk Themed Widgets]]
- [[styling-with-ttk|Styling ttk Widgets With Style]]
- [[dark-mode-color-palette|Building a Dark Terminal Aesthetic]]
- [[custom-fonts|Working With Fonts]]

### 🏗️ [[08 Architecture Patterns MOC|08 — Architecture Patterns]]
Structuring real applications: class-based apps, MVC-lite, threading, and packaging for distribution.

- [[class-based-tkinter-apps|Class Based Application Structure]]
- [[mvc-lite-pattern|MVC Lite Pattern for Tkinter]]
- [[threading-with-tkinter|Threading With Tkinter]]
- [[multi-file-tkinter-projects|Structuring a Multi File Tkinter Project]]
- [[packaging-with-pyinstaller|Packaging a Tkinter App With PyInstaller]]

---

## How to use this vault

1. Start at a domain MOC, read notes in order — each links forward via `See also:`.
2. Use Obsidian's **Graph View** to see the whole domain as a connected web.
3. This is an MVP (~45 notes, fundamentals-weighted). Planned Phase 2 domains: Canvas deep-dive, custom widgets, `asyncio` integration, testing GUIs, advanced Treeview.
4. Perfectionism note to self: **ship the MVP, use it in a real devforge tool, then expand.** Don't let this vault become another mid-build stall.
