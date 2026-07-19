---
tags:
  - project
  - ruby/oop
---

# Project Library Management System (OOP)

## Purpose
A larger OOP project modeling books, members, and lending with multiple collaborating classes.

## Explanation
Design `Book`, `Member`, and `Library` classes that interact: members borrow and return books, and the library tracks availability. This project is where [[Inheritance]], [[Modules]], [[Mixins]] (e.g. mixing in [[Comparable Module]] to sort books), and [[Enumerable Module]] (to filter/search the catalogue) come together in one codebase.

**Stretch goal:** persist the catalogue with [[File IO]] and add search via [[Regular Expressions]].

## Examples
```ruby
class Library
  include Enumerable
  def initialize; @books = []; end
  def each(&block); @books.each(&block); end
  def add(book); @books << book; end
end

library = Library.new
library.select { |b| b.available? }
```

## Related Notes
- [[Inheritance]]
- [[Mixins]]
- [[Enumerable Module]]
- [[Comparable Module]]

## Next Topics
- [[Project Word Frequency Counter]]

## Tags
#project #ruby/oop
