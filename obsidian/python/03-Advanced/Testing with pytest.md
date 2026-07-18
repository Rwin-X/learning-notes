---
title: "Testing with pytest"
difficulty: hard
tags:
  - hard
  - testing
  - advanced
  - tooling
---

# Testing with pytest

`🟠 HARD` #hard

## What it covers
Writing tests with `pytest`: fixtures, parametrize, mocking.

## Key points
- `assert` is all you need — pytest gives readable failure diffs automatically
- `@pytest.fixture` for reusable setup (e.g. a temp file, a mock socket)
- `unittest.mock.patch` to fake network calls in tests so your test suite doesn't need the real internet

## Practice
Write tests for your port-range validator from [[Functions Basics]] and your regex from [[Regular Expressions]].


## Related
- [[Type Hints and Static Typing]]
- [[Modules and Packages]]
