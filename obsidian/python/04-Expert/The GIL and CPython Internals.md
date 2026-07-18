---
title: "The GIL and CPython Internals"
difficulty: expert
tags:
  - expert
  - internals
  - expert
---

# The GIL and CPython Internals

`🔴 EXPERT` #expert

## What it covers
How CPython actually executes bytecode, the Global Interpreter Lock, why it exists.

## Key points
- `dis.dis(func)` shows you the bytecode Python actually runs
- The GIL exists because CPython's memory management (refcounting) isn't thread-safe by default
- Free-threaded (no-GIL) CPython builds are an active, evolving area — worth searching current status when relevant

## Practice
Run `dis.dis()` on a simple function and a list comprehension; compare instruction counts.


## Related
- [[Concurrency - Threading]]
- [[Memory Management and Garbage Collection]]
