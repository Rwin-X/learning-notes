---
tags:
  - ruby/ecosystem
---

# Ruby Style Guide (Rubocop)

## Purpose
Write idiomatic, consistent Ruby using the community style guide and linter.

## Explanation
RuboCop is a static code analyzer that enforces the community Ruby Style Guide — consistent indentation, naming conventions, and idiom preferences (like favoring `select` over verbose loops from [[Loops and Iterators]]).

Running RuboCop against your own [[Projects MOC|projects]] is one of the fastest ways to internalize idiomatic Ruby style as a beginner.

## Examples
```bash
gem install rubocop
rubocop app.rb
```
```ruby
# RuboCop flags this:
if x == true
# and suggests:
if x
```

## Related Notes
- [[RSpec Testing Basics]]
- [[Loops and Iterators]]

## Next Topics
- [[Ruby on Rails Overview]]
- [[Version Managers (rbenv rvm)]]

## Tags
#ruby/ecosystem
