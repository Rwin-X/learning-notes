---
title: "OSINT Scripting Basics"
difficulty: medium
tags:
  - medium
  - security
  - osint
---

# OSINT Scripting Basics

`🟡 MEDIUM` #medium

## What it covers
Automating public-information gathering — the pattern behind your `inOs` async username checker.

## Key points
- Rate-limit aggressively; most platforms will block/ban fast async hammering
- `asyncio` + `aiohttp` (async version of `requests`) is the standard stack for checking many endpoints concurrently
- Always respect platform ToS — OSINT tooling sits in a gray area legally/ethically depending on target and jurisdiction

## Practice
Extend `inOs`-style logic to check 3 more platforms, with a shared rate-limiter.


## Related
- [[Concurrency - Asyncio]]
- [[Working with APIs (requests)]]
