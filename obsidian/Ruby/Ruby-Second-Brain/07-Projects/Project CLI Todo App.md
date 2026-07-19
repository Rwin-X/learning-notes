---
tags:
  - project
  - ruby/collections
---

# Project CLI Todo App

## Purpose
Build a command-line todo list to practice arrays, methods, and loops.

## Explanation
A todo app that supports adding, listing, completing, and removing tasks stored in an in-memory array. This project bridges [[Foundations MOC]] into [[Collections MOC]], since the task list itself is an [[Arrays|Array]] of [[Hashes|Hash]] objects.

**Stretch goal:** persist the list to disk using [[File IO]], turning this into a precursor for [[Project Contact Book with File Persistence]].

## Examples
```ruby
tasks = []

def add_task(tasks, name)
  tasks << { name: name, done: false }
end

add_task(tasks, "Learn Ruby")
tasks.each { |t| puts "[#{t[:done] ? 'x' : ' '}] #{t[:name]}" }
```

## Related Notes
- [[Arrays]]
- [[Hashes]]
- [[Methods (Defining)]]
- [[File IO]]

## Next Topics
- [[Project Simple Bank Account System]]

## Tags
#project #ruby/collections
