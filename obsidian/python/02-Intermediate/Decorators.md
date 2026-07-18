---
title: "Decorators"
difficulty: medium
tags:
  - medium
  - functions
  - intermediate
  - idioms
---

# Decorators

`🟡 MEDIUM` #medium

## What it covers
Functions that wrap other functions to extend behavior without modifying them.

## Key points
- `@decorator` sugar is just `func = decorator(func)`
- Use `functools.wraps` to preserve the original function's metadata
- Extremely common pattern for logging, timing, and **auth checks** in real tools

## Practice
Write a `@timed` decorator that prints how long a function took — you'll reuse this in almost every project.


## Related
- [[Scope and Closures]]
- [[Generators and Iterators]]
- [[Context Managers]]
