---
title: "Concurrency - Threading"
difficulty: hard
tags:
  - hard
  - concurrency
  - advanced
---

# Concurrency - Threading

`🟠 HARD` #hard

## What it covers
The `threading` module, the GIL, thread safety, `Lock`.

## Key points
- The **GIL** (Global Interpreter Lock) means threads don't give true CPU parallelism in CPython — but they're still great for I/O-bound work (network requests, file reads)
- Race conditions happen when threads share mutable state without a `Lock`
- `concurrent.futures.ThreadPoolExecutor` is the modern, simpler API over raw `threading`

## Practice
Build a multithreaded port scanner using `ThreadPoolExecutor` — classic security-tooling use case for threading.


## Related
- [[Working with Sockets]]
- [[Concurrency - Asyncio]]
- [[Concurrency - Multiprocessing]]
