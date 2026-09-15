---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# if

> if runs a block of code only when a condition is true, using test expressions inside [ ] or [[ ]].

## Syntax
```bash
if [ condition ]; then
  commands
fi
```

## Example
```bash
$ count=5
$ if [ "$count" -gt 3 ]; then echo "big"; fi
```

## Expected output
```
big
```

## ⚠️ Common mistake
Forgetting spaces inside the brackets — [ "$x"-gt 3 ] (no space) causes a syntax error, since [ is actually a command needing arguments.

## 💡 Practical use
Used constantly for validating input, checking exit codes, and branching logic in every non-trivial script.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
