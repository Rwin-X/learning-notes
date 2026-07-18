---
title: "Concurrency - Asyncio"
difficulty: hard
tags:
  - hard
  - concurrency
  - advanced
  - networking
---

# Concurrency - Asyncio

`🟠 HARD` #hard

## What it covers
`async`/`await`, the event loop, coroutines, `asyncio.gather`.

## Key points
- Single-threaded concurrency via cooperative multitasking — great for thousands of I/O-bound tasks (e.g. your `inOs` async OSINT checker)
- `await` yields control back to the event loop while waiting on I/O
- Mixing blocking calls into async code stalls the whole event loop — use `asyncio.to_thread()` for blocking calls

## Practice
Rewrite the threaded port scanner from [[Concurrency - Threading]] using `asyncio` + `asyncio.open_connection`.


## Related
- [[Concurrency - Threading]]
- [[Working with Sockets]]
- [[Working with APIs (requests)]]
