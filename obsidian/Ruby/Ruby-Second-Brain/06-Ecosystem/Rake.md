---
tags:
  - ruby/ecosystem
---

# Rake

## Purpose
Automate repetitive tasks with Ruby's build/task tool.

## Explanation
Rake (Ruby Make) lets you define tasks in a `Rakefile` using plain Ruby, commonly used for database migrations, test running, and deployment scripts in [[Ruby on Rails Overview|Rails]] projects.

Rake tasks are just methods wrapped in a DSL, another practical example of the block-and-DSL patterns from [[Blocks Procs and Lambdas]].

## Examples
```ruby
# Rakefile
task :greet do
  puts "Hello from Rake!"
end
```
```bash
rake greet
```

## Related Notes
- [[RSpec Testing Basics]]
- [[Blocks Procs and Lambdas]]

## Next Topics
- [[Ruby Style Guide (Rubocop)]]
- [[Ruby on Rails Overview]]

## Tags
#ruby/ecosystem
