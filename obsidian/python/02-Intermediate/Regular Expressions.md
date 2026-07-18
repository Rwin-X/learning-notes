---
title: "Regular Expressions"
difficulty: medium
tags:
  - medium
  - strings
  - intermediate
  - parsing
---

# Regular Expressions

`🟡 MEDIUM` #medium

## What it covers
The `re` module — pattern matching, groups, `re.search` vs `re.match` vs `re.findall`.

## Key points
- `re.compile()` a pattern once if reusing it in a loop — faster
- Named groups: `(?P<year>\d{4})`
- Extremely useful for **log parsing** and **input validation** (e.g. matching IP addresses, emails)

## Practice
Write a regex that extracts all IPv4 addresses from a log file.


## Related
- [[Strings Deep Dive]]
- [[Working with Log Parsing]]
