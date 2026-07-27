# Tkinter Second Brain — Obsidian Vault

Generated 2026-07-27 · 8 domains · 45 atomic notes

## Setup

1. Open Obsidian → **Open folder as vault** → select this directory.
2. Start at `00 Tkinter MOC.md`.
3. Enable **Graph View** (left ribbon) to see the note web.

## Structure

```
TkinterVault/
├── 00 Tkinter MOC.md          ← start here
├── 01-core-concepts/
│   ├── 01 Core Concepts MOC.md
│   └── *.md  (atomic notes)
├── 02-geometry-managers/
├── 03-core-widgets/
├── 04-events-and-binding/
├── 05-variables-and-state/
├── 06-dialogs-menus-windows/
├── 07-styling-and-themes/
└── 08-architecture-patterns/
```

## Regenerating / extending

This vault is produced by `generate_vault.py` (pure stdlib, no dependencies).
To add notes: edit the `DOMAINS` list in the script and re-run — it's idempotent
and will overwrite existing generated files cleanly.

```bash
python generate_vault.py --out ./TkinterVault
python generate_vault.py --validate   # check all [[wikilinks]] resolve to real notes
```

## Phase 2 (not yet built)

- Canvas deep-dive (animations, custom widget drawing)
- Custom widget subclassing
- `asyncio` + Tkinter integration patterns
- Testing Tkinter GUIs (pytest + widget interaction)
- Advanced Treeview (sortable columns, embedded data tables)
- Drag-and-drop
