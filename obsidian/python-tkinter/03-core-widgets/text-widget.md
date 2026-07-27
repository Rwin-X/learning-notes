---
title: "Text Widget"
domain: "03-core-widgets"
tags: [widgets, text, input]
created: 2026-07-27
type: atomic-note
---

# Text Widget

#widgets #text #input

`Text` is a multi-line, richly-formattable text area — think of it as `Entry`'s big sibling, used for logs, code output, or long-form input.

```python
text = tk.Text(root, height=10, width=50, bg="#0d1117", fg="#00ff9f", insertbackground="white")
text.insert("1.0", "Line one\nLine two")   # "1.0" = line 1, char 0
content = text.get("1.0", "end")
text.delete("1.0", "end")
text.config(state="disabled")  # read-only log display — re-enable to write, then disable again
```

Index format is always `"line.char"` (1-indexed lines, 0-indexed chars), or symbolic marks like `"end"`, `"insert"` (cursor position).

For colored log output (e.g. a cyber_news-style terminal panel) use **tags**:

```python
text.tag_config("error", foreground="#ff4444")
text.insert("end", "Connection failed\n", "error")
```

See also: [[entry-widget]], [[scrollbar-widget]], [[building-a-log-console]]

---
📍 Part of [[03 Core Widgets MOC|Core Widgets MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
