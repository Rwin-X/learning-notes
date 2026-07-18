---
title: "Functions Basics"
difficulty: easy
tags:
  - easy
  - syntax
  - functions
---

# Functions Basics

`🟢 EASY` #easy

## What it covers
Defining functions, parameters, return values, default args, `*args`/`**kwargs`.

## Key points
- Default args are evaluated **once** — never use mutable defaults (`def f(x=[])` is a classic bug)
- `*args` collects positional args into a tuple, `**kwargs` into a dict
- Docstrings: `"""Summary."""` right under the `def` line

## Practice
Write a `port_in_range(port)` validator function returning bool — small, but this exact shape appears in real scanner scripts.


## Related
- [[Lists and Tuples]]
- [[Scope and Closures]]
- [[List Comprehensions]]
