---
title: "Concurrency - Multiprocessing"
difficulty: hard
tags:
  - hard
  - concurrency
  - advanced
---

# Concurrency - Multiprocessing

`🟠 HARD` #hard

## What it covers
The `multiprocessing` module for true CPU parallelism (bypasses the GIL).

## Key points
- Use for CPU-bound work: hashing, image processing, heavy computation
- Each process has its own memory — use `Queue` or `Pipe` to communicate
- `ProcessPoolExecutor` mirrors the `ThreadPoolExecutor` API for easy switching

## Practice
Parallelize a hash-cracking demo (against a small known wordlist you control) using `ProcessPoolExecutor` to compare against the threaded version's speed.


## Related
- [[Concurrency - Threading]]
