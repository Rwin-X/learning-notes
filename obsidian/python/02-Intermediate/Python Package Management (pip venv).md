---
title: "Python Package Management (pip venv)"
difficulty: medium
tags:
  - medium
  - tooling
  - intermediate
---

# Python Package Management (pip venv)

`🟡 MEDIUM` #medium

## What it covers
`pip`, `requirements.txt`, `venv`, and an intro to `poetry`/`uv` as modern alternatives.

## Key points
- `pip freeze > requirements.txt` to snapshot dependencies
- Never install project dependencies globally — always inside a `.venv`
- `pip install -e .` for editable/local package installs during development

## Practice
Turn one existing `devforge` script into an installable package with a `pyproject.toml`.


## Related
- [[Python Setup and Environment]]
- [[Modules and Packages]]
