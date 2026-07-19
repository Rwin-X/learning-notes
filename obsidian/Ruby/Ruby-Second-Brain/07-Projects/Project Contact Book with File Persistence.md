---
tags:
  - project
  - ruby/advanced
---

# Project Contact Book with File Persistence

## Purpose
Capstone project: combine OOP, collections, and file I/O into one persistent CLI app.

## Explanation
Build a contact book that stores `Contact` objects (name, phone, email) and persists them to a file between runs, loading and saving as [[Nested Data Structures]]. This is the natural capstone of the beginner-to-advanced path — it draws on [[Classes and Objects]], [[File IO]], [[Exception Handling Advanced]], and [[Regular Expressions]] (validating email format) simultaneously.

**Stretch goal:** add search using [[Enumerable Deep Dive]] and export to CSV.

## Examples
```ruby
require 'json'

class Contact
  attr_accessor :name, :phone
  def initialize(name, phone); @name = name; @phone = phone; end
  def to_h; { name: name, phone: phone }; end
end

File.write("contacts.json", [c1.to_h, c2.to_h].to_json)
```

## Related Notes
- [[Classes and Objects]]
- [[File IO]]
- [[Nested Data Structures]]
- [[Exception Handling Advanced]]

## Next Topics
- *(none — see MOC for continuation)*

## Tags
#project #ruby/advanced
