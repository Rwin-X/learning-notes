---
title: "Inheritance and Polymorphism"
difficulty: hard
tags:
  - hard
  - oop
  - advanced
---

# Inheritance and Polymorphism

`🟠 HARD` #hard

## What it covers
Subclassing, `super()`, method overriding, duck typing, ABCs.

## Key points
- `super().__init__()` calls the parent constructor — don't forget it
- Python favors **duck typing** over strict interfaces, but `abc.ABC` gives you real abstract base classes when you need enforcement
- Multiple inheritance follows MRO (Method Resolution Order / C3 linearization)

## Practice
Build a `BaseScanner` abstract class with `PortScanner` and `VulnScanner` subclasses.


## Related
- [[Object-Oriented Programming Basics]]
- [[Dataclasses]]
- [[Design Patterns in Python]]
