---
tags:
  - project
  - ruby/basics
---

# Project Number Guessing Game

## Purpose
First mini-project: apply loops, conditionals, and I/O together.

## Explanation
Build a CLI game where the computer picks a random number and the player guesses until correct, receiving "higher/lower" hints. This project is the natural first application after finishing [[Foundations MOC]] — it exercises [[Loops and Iterators]], [[Conditionals]], and [[Input and Output]] together.

**Stretch goal:** track guess count and add difficulty levels using [[Ranges]].

## Examples
```ruby
secret = rand(1..100)
guess = nil

until guess == secret
  print "Guess a number 1-100: "
  guess = gets.chomp.to_i
  puts guess < secret ? "Higher!" : "Lower!" if guess != secret
end

puts "You got it!"
```

## Related Notes
- [[Loops and Iterators]]
- [[Conditionals]]
- [[Input and Output]]
- [[Ranges]]

## Next Topics
- [[Project CLI Todo App]]

## Tags
#project #ruby/basics
