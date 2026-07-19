---
tags:
  - cheatsheet
  - ruby/collections
---

# Cheatsheet Enumerable Methods

## Purpose
Quick reference for the Enumerable module's method catalogue.

## Explanation
The single most valuable cheatsheet in this vault — a fast lookup for the [[Enumerable Deep Dive]] method set that appears in nearly every idiomatic Ruby codebase.

## Examples
```ruby
arr.map { }        # transform
arr.select { }      # filter (keep true)
arr.reject { }      # filter (keep false)
arr.reduce(0) { }   # fold to single value
arr.find { }        # first match
arr.all? / any? / none? { }
arr.sort_by { }
arr.group_by { }
arr.tally           # count occurrences
```

## Related Notes
- [[Enumerable Deep Dive]]
- [[Enumerable Module]]
- [[Array Methods (map select reduce)]]

## Next Topics
- [[Cheatsheet Regex]]

## Tags
#cheatsheet #ruby/collections
