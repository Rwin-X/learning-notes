---
title: "Generators and Iterators"
difficulty: medium
tags:
  - medium
  - functions
  - intermediate
  - performance
---

# Generators and Iterators

`🟡 MEDIUM` #medium

## What it covers
`yield`, generator expressions, the iterator protocol (`__iter__`/`__next__`).

## Key points
- Generators are lazy — they don't hold the whole sequence in memory
- Great for streaming large files (e.g. huge log files, pcap data) without loading everything at once
- `yield from` delegates to a sub-generator

## Practice
Write a generator that reads a huge log file line-by-line and yields only lines matching a keyword.


## Related
- [[Decorators]]
- [[File IO]]
- [[Iterators and itertools]]
