---
title: "Working with Sockets"
difficulty: hard
tags:
  - hard
  - networking
  - advanced
---

# Working with Sockets

`🟠 HARD` #hard

## What it covers
The `socket` module — raw TCP/UDP communication.

## Key points
- `socket.socket(AF_INET, SOCK_STREAM)` for TCP, `SOCK_DGRAM` for UDP
- Always set a `settimeout()` — an unbounded socket read can hang forever
- This is the foundation underneath every scanner, honeypot, and chat server you've built

## Practice
Write a minimal TCP echo server and client pair from scratch (no libraries beyond `socket`).


## Related
- [[Concurrency - Threading]]
- [[Concurrency - Asyncio]]
- [[Building a Port Scanner]]
