---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Functions

> Functions group commands into a reusable, named block, keeping scripts organized and avoiding repetition.

## Syntax
```bash
function_name() {
  commands
}
```

## Example
```bash
$ greet() { echo "Hello, $1"; }
$ greet Rwin
```

## Expected output
```
Hello, Rwin
```

## ⚠️ Common mistake
Forgetting that Bash functions don't return values like other languages — they return exit codes; use echo and command substitution to "return" data.

## 💡 Practical use
Any script over ~20 lines benefits from being broken into functions like check_dependencies, log_message, and cleanup.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
