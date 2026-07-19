---
tags:
  - ruby/oop
---

# Structs

## Purpose
Quickly create simple value-holding classes without boilerplate.

## Explanation
`Struct.new` generates a lightweight class with accessors already defined — great for simple data objects where writing a full class with [[Attributes (attr_accessor)]] would be overkill.

Structs are commonly used in small [[Projects MOC|projects]] and scripts where you need a quick, named data container.

## Examples
```ruby
Point = Struct.new(:x, :y) do
  def distance_from_origin
    Math.sqrt(x**2 + y**2)
  end
end

p1 = Point.new(3, 4)
p1.distance_from_origin   #=> 5.0
```

## Related Notes
- [[Attributes (attr_accessor)]]
- [[Classes and Objects]]
- [[Comparable Module]]

## Next Topics
- [[Arrays]]
- [[Hashes]]

## Tags
#ruby/oop
