---
title: "File IO"
difficulty: medium
tags:
  - medium
  - io
  - intermediate
---

# File IO

`🟡 MEDIUM` #medium

## What it covers
Reading/writing text and binary files, `with` blocks, `pathlib`.

## Key points
- Always use `with open(...) as f:` — guarantees the file closes even on error
- `"rb"` / `"wb"` modes for binary (crucial for working with binary protocols, images, encrypted blobs)
- `pathlib.Path` is the modern, cross-platform way to handle paths

## Practice
Write a script that reads a directory of `.txt` files and reports total line count per file.


## Related
- [[Strings Deep Dive]]
- [[Exception Handling]]
- [[Working with JSON and CSV]]
