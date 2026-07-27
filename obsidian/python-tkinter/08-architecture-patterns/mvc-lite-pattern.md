---
title: "MVC Lite Pattern for Tkinter"
domain: "08-architecture-patterns"
tags: [architecture, mvc]
created: 2026-07-27
type: atomic-note
---

# MVC Lite Pattern for Tkinter

#architecture #mvc

Full MVC is often overkill for a Tkinter tool, but a **light separation** between data/logic and widgets pays off fast as an app grows past ~200 lines — the same instinct behind your file threat-analysis engine's separation of scoring logic from CLI presentation.

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

See also: [[class-based-tkinter-apps]], [[multi-file-tkinter-projects]]

---
📍 Part of [[08 Architecture Patterns MOC|Architecture Patterns MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
