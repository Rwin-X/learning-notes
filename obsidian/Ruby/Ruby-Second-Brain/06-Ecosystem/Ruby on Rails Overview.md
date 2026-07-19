---
tags:
  - ruby/ecosystem
---

# Ruby on Rails Overview

## Purpose
Understand what Rails is and how it relates to the Ruby language itself.

## Explanation
Rails is a full-stack web framework built in Ruby, following **convention-over-configuration** and MVC architecture. It's the single biggest reason Ruby became popular, but it's built *on top of* the language — everything in the [[Ruby MOC]] applies inside Rails too.

Rails leans heavily on metaprogramming ([[Method Missing]], [[Define Method]], [[Open Classes]]) to create its expressive, low-boilerplate APIs (like ActiveRecord's dynamic finder methods).

## Examples
```ruby
# A Rails model -- looks like plain Ruby, but gains huge functionality
# from ActiveRecord via inheritance and metaprogramming
class User < ApplicationRecord
  validates :email, presence: true
end
```

## Related Notes
- [[Method Missing]]
- [[Define Method]]
- [[Open Classes]]
- [[Gems and Bundler]]

## Next Topics
- [[Version Managers (rbenv rvm)]]

## Tags
#ruby/ecosystem
