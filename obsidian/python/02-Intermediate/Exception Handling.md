---
title: "Exception Handling"
difficulty: medium
tags:
  - medium
  - error-handling
  - intermediate
---

# Exception Handling

`🟡 MEDIUM` #medium

## What it covers
`try`/`except`/`else`/`finally`, custom exceptions, exception chaining.

## Key points
- Catch **specific** exceptions, never a bare `except:`
- `finally` always runs — good for cleanup (closing sockets, files)
- Custom exceptions: `class InvalidPortError(Exception): pass`

## Practice
Wrap a network request function with proper exception handling for `ConnectionError` and `TimeoutError`.


## Related
- [[File IO]]
- [[Context Managers]]
- [[Logging]]
