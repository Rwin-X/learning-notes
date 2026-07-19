---
tags:
  - ruby/basics
---

# Installing Ruby

## Purpose
Get a working Ruby environment set up so you can run code locally.

## Explanation
Ruby can be installed directly, but most Rubyists use a **version manager** so they can switch Ruby versions per project — see [[Version Managers (rbenv rvm)]] for why this matters.

Once installed, `ruby -v` confirms the version, and `irb` (Interactive Ruby) gives you a REPL to experiment in — invaluable while working through [[Ruby Syntax Basics]].

## Examples
```bash
# Check installation
ruby -v

# Launch the REPL
irb
irb(main):001:0> puts "it works"
it works
```

## Related Notes
- [[What Is Ruby]]
- [[Version Managers (rbenv rvm)]]
- [[Gems and Bundler]]

## Next Topics
- [[Ruby Syntax Basics]]

## Tags
#ruby/basics
