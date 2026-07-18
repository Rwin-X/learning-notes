---
title: "Context Managers"
difficulty: medium
tags:
  - medium
  - intermediate
  - idioms
---

# Context Managers

`🟡 MEDIUM` #medium

## What it covers
The `with` statement, writing your own context managers via `__enter__`/`__exit__` or `contextlib`.

## Key points
- `with` guarantees setup/teardown even on exceptions — used for files, sockets, DB connections, locks
- `@contextlib.contextmanager` lets you write one using a generator + `yield`
- Common in security tooling for things like "temporarily elevate permissions, then always drop them"

## Practice
Write a context manager that times a code block (compare to your `@timed` decorator from [[Decorators]]).


## Related
- [[Decorators]]
- [[Exception Handling]]
- [[Working with Sockets]]
