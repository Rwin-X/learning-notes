---
tags:
  - ruby/ecosystem
---

# RubyGems

## Purpose
Understand the public package registry that gems are published to.

## Explanation
RubyGems.org is the central repository where open-source gems are published and downloaded from. The `gem` command-line tool installs, lists, and manages gems directly, independent of [[Gems and Bundler|Bundler]]'s project-level locking.

Knowing how to search and vet gems here is a practical skill for any real-world Ruby work.

## Examples
```bash
gem install rails
gem list
gem search json
```

## Related Notes
- [[Gems and Bundler]]
- [[Version Managers (rbenv rvm)]]

## Next Topics
- [[RSpec Testing Basics]]
- [[Rake]]

## Tags
#ruby/ecosystem
