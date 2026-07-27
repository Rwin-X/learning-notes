---
title: "Tkinter vs PyQt6 PySide6"
domain: "01-core-concepts"
tags: [core, comparison]
created: 2026-07-27
type: atomic-note
---

# Tkinter vs PyQt6 PySide6

#core #comparison

You already ship production PySide6 apps (password manager, StegoForge, Idea Book). Here's when Tkinter is the *better* choice, not just the easier one:

| Use Tkinter when | Use PySide6/PyQt6 when |
|---|---|
| Zero-dependency requirement (stdlib only) | You need modern theming out of the box |
| Quick internal tool / one-off script GUI | Shipping a polished product |
| Teaching / learning GUI concepts fast | Complex widgets (graphs, force-directed views) |
| Air-gapped or restricted environments | You need QThread-grade concurrency tooling |

Architecturally the concepts transfer directly: [[the-event-loop]] ≈ Qt's event loop, [[widget-hierarchy]] ≈ Qt's parent/child tree, [[tkinter-variables]] ≈ Qt's signal-driven state. Learning Tkinter well makes you *faster* at PySide6, not redundant with it.

See also: [[what-is-tkinter]], [[the-event-loop]]

---
📍 Part of [[01 Core Concepts MOC|Core Concepts MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
