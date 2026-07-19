---
tags:
  - ruby/collections
---

# Enumerable Deep Dive

## Purpose
Catalogue the full power of the Enumerable module beyond the basics.

## Explanation
Beyond `map`/`select`/`reduce`, `Enumerable` provides `sort_by`, `group_by`, `partition`, `find` (alias `detect`), `all?`, `any?`, `none?`, `tally`, and more. Mastering this module is arguably the single highest-leverage skill for writing idiomatic Ruby.

This note ties directly back to [[Enumerable Module]] (how your own classes gain these powers) and to [[Cheatsheet Enumerable Methods]] for quick reference.

## Examples
```ruby
words = %w[apple banana kiwi cherry]

words.group_by(&:length)     #=> {5=>["apple"], 6=>["banana","cherry"], 4=>["kiwi"]}
words.sort_by(&:length)      #=> ["kiwi","apple","banana","cherry"]
words.partition { |w| w.length > 5 }  #=> [["banana","cherry"], ["apple","kiwi"]]
```

## Related Notes
- [[Iterators Deep Dive]]
- [[Enumerable Module]]
- [[Cheatsheet Enumerable Methods]]

## Next Topics
- [[Sets]]
- [[Nested Data Structures]]

## Tags
#ruby/collections
