---
title: "Type Hints and Static Typing"
difficulty: hard
tags:
  - hard
  - typing
  - advanced
  - tooling
---

# Type Hints and Static Typing

`🟠 HARD` #hard

## What it covers
`typing` module, `mypy`, gradual typing philosophy.

## Key points
- `def scan(host: str, port: int) -> bool:` — hints don't enforce at runtime, they're for tooling/readability
- `Optional[X]`, `Union[X, Y]`, `list[str]` (3.9+)
- Run `mypy` in CI to catch type errors before they become bugs

## Practice
Add full type hints to one of your existing `devforge` scripts and run `mypy` on it.


## Related
- [[Dataclasses]]
- [[Testing with pytest]]
