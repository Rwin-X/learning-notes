---
title: "Performance Profiling"
difficulty: expert
tags:
  - expert
  - performance
  - expert
  - tooling
---

# Performance Profiling

`🔴 EXPERT` #expert

## What it covers
`cProfile`, `timeit`, `line_profiler`, identifying real bottlenecks instead of guessing.

## Key points
- Never optimize before profiling — intuition about "slow code" is often wrong
- `python -m cProfile -s cumulative script.py` gives a quick sorted report
- `timeit` for micro-benchmarking small snippets in isolation

## Practice
Profile your threaded vs asyncio port scanners from [[Concurrency - Threading]] / [[Concurrency - Asyncio]] and compare real numbers.


## Related
- [[Memory Management and Garbage Collection]]
- [[Concurrency - Asyncio]]
