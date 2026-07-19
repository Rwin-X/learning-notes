---
tags:
  - ruby/oop
---

# Enumerable Module

## Purpose
Give your custom objects `map`, `select`, `sort`, and dozens of other methods by defining `each`.

## Explanation
Include the `Enumerable` module and define an `each` method, and your class gains the entire Enumerable method set — `map`, `select`, `reduce`, `sort`, `min`, `max`, and more, all covered in [[Enumerable Deep Dive]].

This is the same pattern as [[Comparable Module]]: implement one core method, gain a whole family of behavior via [[Mixins]]. `Array` and `Hash` themselves are built this way.

## Examples
```ruby
class Playlist
  include Enumerable
  def initialize(songs); @songs = songs; end
  def each
    @songs.each { |s| yield s }
  end
end

pl = Playlist.new(["A", "B", "C"])
pl.map(&:downcase)   #=> ["a", "b", "c"]
```

## Related Notes
- [[Comparable Module]]
- [[Mixins]]
- [[Enumerable Deep Dive]]
- [[Arrays]]

## Next Topics
- [[Structs]]
- [[Arrays]]

## Tags
#ruby/oop
