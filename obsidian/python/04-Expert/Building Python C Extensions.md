---
title: "Building Python C Extensions"
difficulty: expert
tags:
  - expert
  - internals
  - expert
  - performance
---

# Building Python C Extensions

`🔴 EXPERT` #expert

## What it covers
Speeding up hot paths with C extensions, `ctypes`, and an intro to `Cython`.

## Key points
- `ctypes` lets you call existing C libraries directly from Python without writing an extension
- `Cython` compiles Python-like code to C for near-native speed on hot loops
- Reach for this only after profiling ([[Performance Profiling]]) proves you need it

## Practice
Use `ctypes` to call a simple function from a system library (e.g. `libc`'s `time()`).


## Related
- [[Performance Profiling]]
- [[The GIL and CPython Internals]]
