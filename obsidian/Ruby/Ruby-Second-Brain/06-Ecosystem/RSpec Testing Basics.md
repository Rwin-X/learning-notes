---
tags:
  - ruby/ecosystem
---

# RSpec Testing Basics

## Purpose
Write automated tests for Ruby code using the RSpec framework.

## Explanation
RSpec is Ruby's most popular testing framework, using a readable `describe`/`it`/`expect` DSL built with the metaprogramming techniques from [[Class Eval and Instance Eval]] and [[Method Missing]].

Testing your own [[Projects MOC|projects]] with RSpec is one of the best ways to solidify OOP concepts like [[Classes and Objects]] and [[Method Visibility]].

## Examples
```ruby
RSpec.describe "Addition" do
  it "adds two numbers" do
    expect(2 + 2).to eq(4)
  end
end
```

## Related Notes
- [[Gems and Bundler]]
- [[Class Eval and Instance Eval]]
- [[Ruby Style Guide (Rubocop)]]

## Next Topics
- [[Rake]]
- [[Ruby Style Guide (Rubocop)]]

## Tags
#ruby/ecosystem
