---
title: "Working with CLI Arguments (argparse)"
difficulty: medium
tags:
  - medium
  - cli
  - intermediate
  - tooling
---

# Working with CLI Arguments (argparse)

`🟡 MEDIUM` #medium

## What it covers
Building real command-line tools using `argparse` (and a note on `click`/`typer`).

## Key points
- `argparse.ArgumentParser()` + `add_argument()` gives you `--help` for free
- Subcommands via `add_subparsers()` — e.g. `mytool scan` vs `mytool report`
- This is the standard way to structure the CLI tools you already build (like METAINSPECT)

## Practice
Add proper `argparse` flags (`--output json`, `--verbose`) to one of your existing CLI scripts.


## Related
- [[Modules and Packages]]
- [[Logging]]
