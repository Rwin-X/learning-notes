---
title: "Variable Tracing"
domain: "05-variables-and-state"
tags: [state, variables, callbacks]
created: 2026-07-27
type: atomic-note
---

# Variable Tracing

#state #variables #callbacks

`.trace_add(mode, callback)` runs a callback automatically whenever a Tkinter variable changes — this is how you build reactive UI without manually wiring every widget update.

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

See also: [[tkinter-variables]], [[the-after-method]]

---
📍 Part of [[05 Variables and State MOC|Variables and State MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
