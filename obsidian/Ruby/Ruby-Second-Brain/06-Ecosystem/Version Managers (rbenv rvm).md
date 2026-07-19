---
tags:
  - ruby/ecosystem
---

# Version Managers (rbenv rvm)

## Purpose
Manage multiple Ruby versions across different projects cleanly.

## Explanation
Tools like `rbenv` and `rvm` let you install and switch between multiple Ruby versions per-project, avoiding conflicts between a system Ruby and project requirements. This is typically the very first practical tool set up after [[Installing Ruby]].

This note closes the loop of the [[Ecosystem MOC]] back to day-one setup, reinforcing the graph's cyclical structure between beginner and practical topics.

## Examples
```bash
rbenv install 3.3.0
rbenv local 3.3.0   # pin version for this project
ruby -v              # confirm active version
```

## Related Notes
- [[Installing Ruby]]
- [[RubyGems]]
- [[Ruby on Rails Overview]]

## Next Topics
- [[Installing Ruby]]

## Tags
#ruby/ecosystem
