---
title: "Class Based Application Structure"
domain: "08-architecture-patterns"
tags: [architecture, oop]
created: 2026-07-27
type: atomic-note
---

# Class Based Application Structure

#architecture #oop

Beyond trivial scripts, wrap the app in a class inheriting from `tk.Tk` (or composing one) — this is the direct Tkinter analog to the `QMainWindow` subclassing pattern you already use in PySide6.

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
        self.output.insert("end", f"Scanning {target}...\n")

if __name__ == "__main__":
    app = ScannerApp()
    app.mainloop()
```

Benefits over a flat script: widgets become `self.` attributes accessible from any method (no global variables), the app is trivially testable/importable, and it scales cleanly into [[mvc-lite-pattern]] as complexity grows.

See also: [[mvc-lite-pattern]], [[multi-file-tkinter-projects]]

---
📍 Part of [[08 Architecture Patterns MOC|Architecture Patterns MOC]] · 🗺️ [[00 Tkinter MOC|Vault Home]]
