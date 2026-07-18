---
title: "Metaclasses and Descriptors"
difficulty: expert
tags:
  - expert
  - oop
  - expert
  - internals
---

# Metaclasses and Descriptors

`🔴 EXPERT` #expert

## What it covers
`type()`, custom metaclasses, the descriptor protocol (`__get__`/`__set__`).

## Key points
- A metaclass is "the class of a class" — `type` is the default metaclass
- Descriptors power `@property`, ORMs, and validation frameworks under the hood
- Use sparingly — this is powerful but hurts readability if overused

## Practice
Implement a descriptor that validates an attribute is always a valid port number (0-65535) on assignment.


## Related
- [[Inheritance and Polymorphism]]
- [[Dataclasses]]
