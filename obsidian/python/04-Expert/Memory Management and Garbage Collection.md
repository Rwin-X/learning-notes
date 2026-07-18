---
title: "Memory Management and Garbage Collection"
difficulty: expert
tags:
  - expert
  - internals
  - expert
  - performance
---

# Memory Management and Garbage Collection

`🔴 EXPERT` #expert

## What it covers
Reference counting, the generational garbage collector, `weakref`, `__slots__`.

## Key points
- CPython primarily uses **reference counting**; the cyclic GC handles reference cycles
- `__slots__` on a class avoids per-instance `__dict__`, saving memory at scale
- `weakref` lets you reference an object without keeping it alive — useful for caches

## Practice
Add `__slots__` to a data-heavy class (like your `NetworkHost`) and reason about the memory tradeoff.


## Related
- [[Dataclasses]]
- [[Performance Profiling]]
