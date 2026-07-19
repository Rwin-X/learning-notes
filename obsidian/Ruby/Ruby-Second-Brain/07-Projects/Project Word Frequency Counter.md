---
tags:
  - project
  - ruby/collections
---

# Project Word Frequency Counter

## Purpose
Practice functional-style collection processing on real text.

## Explanation
Read a block of text and count word frequency, then display the top N most common words. This project is a focused workout for [[Array Methods (map select reduce)]] and [[Enumerable Deep Dive]] (`tally`, `sort_by`, `group_by`), plus a touch of [[Regular Expressions]] for cleaning punctuation.

**Stretch goal:** read from a real file using [[File IO]] instead of a hardcoded string.

## Examples
```ruby
text = "the quick brown fox the lazy dog the fox"

counts = text.split.tally
top = counts.sort_by { |_word, count| -count }.first(2)
top.each { |word, count| puts "#{word}: #{count}" }
#=> the: 3
#=> fox: 2
```

## Related Notes
- [[Array Methods (map select reduce)]]
- [[Enumerable Deep Dive]]
- [[Regular Expressions]]

## Next Topics
- [[Project Contact Book with File Persistence]]

## Tags
#project #ruby/collections
