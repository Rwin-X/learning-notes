---
tags:
  - ruby/ecosystem
---

# Gems and Bundler

## Purpose
Understand Ruby's package system and dependency management.

## Explanation
A **gem** is a packaged Ruby library, distributed via [[RubyGems]]. **Bundler** manages a project's gem dependencies through a `Gemfile`, locking exact versions in `Gemfile.lock` for reproducible environments.

This is the practical bridge from language knowledge to real projects — almost every non-trivial Ruby project, including [[Ruby on Rails Overview|Rails]] apps, relies on Bundler.

## Examples
```ruby
# Gemfile
source "https://rubygems.org"
gem "rspec"
gem "rubocop"
```
```bash
bundle install
bundle exec rspec
```

## Related Notes
- [[Reflection]]
- [[RubyGems]]
- [[RSpec Testing Basics]]

## Next Topics
- [[RubyGems]]
- [[RSpec Testing Basics]]

## Tags
#ruby/ecosystem
