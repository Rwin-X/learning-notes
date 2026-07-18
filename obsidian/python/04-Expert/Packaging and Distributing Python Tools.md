---
title: "Packaging and Distributing Python Tools"
difficulty: expert
tags:
  - expert
  - tooling
  - expert
  - structure
---

# Packaging and Distributing Python Tools

`🔴 EXPERT` #expert

## What it covers
`pyproject.toml`, building wheels, publishing to PyPI, entry points for CLI tools.

## Key points
- `pyproject.toml` is the modern standard (replacing `setup.py` for most cases)
- `[project.scripts]` entry points let `pip install .` create a real `mytool` command
- This is how you'd turn something like METAINSPECT into a `pip install`-able tool

## Practice
Package one existing `devforge` CLI project with a proper `pyproject.toml` and an entry point.


## Related
- [[Python Package Management (pip venv)]]
- [[Testing with pytest]]
