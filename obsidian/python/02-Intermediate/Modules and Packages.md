---
title: "Modules and Packages"
difficulty: medium
tags:
  - medium
  - structure
  - intermediate
---

# Modules and Packages

`🟡 MEDIUM` #medium

## What it covers
`import`, packages, `__init__.py`, relative vs absolute imports, `if __name__ == "__main__"`.

## Key points
- A **package** is a folder with `__init__.py` (or namespace package in 3.3+)
- `if __name__ == "__main__":` guards code that should only run when the file is executed directly, not imported
- This is exactly how you'd structure a `devforge` CLI tool with multiple files

## Practice
Split one of your single-file scripts into a small package with 2-3 modules.


## Related
- [[Python Package Management (pip venv)]]
- [[Working with CLI Arguments (argparse)]]
