---
title: "Dataclasses"
difficulty: hard
tags:
  - hard
  - oop
  - advanced
  - idioms
---

# Dataclasses

`🟠 HARD` #hard

## What it covers
`@dataclass` for boilerplate-free data-holding classes.

## Key points
- Auto-generates `__init__`, `__repr__`, `__eq__`
- `field(default_factory=list)` for mutable defaults
- `frozen=True` makes instances immutable (good for config objects)

## Practice
Convert your `NetworkHost` class from [[Object-Oriented Programming Basics]] into a `@dataclass`.


## Related
- [[Object-Oriented Programming Basics]]
- [[Type Hints and Static Typing]]
