---
title: "Building a Port Scanner"
difficulty: hard
tags:
  - hard
  - security
  - networking
  - project
---

# Building a Port Scanner

`🟠 HARD` #hard

## What it covers
Combining [[Working with Sockets]] + [[Concurrency - Threading]] into a real (lab-safe) TCP port scanner.

## Key points
- Sweep a port range with a thread pool, `connect_ex()` instead of `connect()` to avoid exceptions on closed ports
- Always default to scanning `127.0.0.1` or a lab VM you own
- Output structured results (JSON) so it composes with other tools — echoes your METAINSPECT `--json` pattern

## Practice
Extend it with `--ports 1-1024` via [[Working with CLI Arguments (argparse)]] and JSON output via [[Working with JSON and CSV]].


## Related
- [[Working with Sockets]]
- [[Concurrency - Threading]]
- [[Working with CLI Arguments (argparse)]]
