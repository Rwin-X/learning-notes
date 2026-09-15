---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# Command chaining

> Beyond pipes, commands can be chained with ; (run regardless), && (run if success), and || (run if failure) to control execution flow on one line.

## Syntax
```bash
cmd1; cmd2
cmd1 && cmd2
cmd1 || cmd2
```

## Example
```bash
$ cd /tmp; touch test.txt; ls test.txt
```

## Expected output
```
test.txt
```

## ⚠️ Common mistake
Using ; when && was intended — a failed first command with ; still lets the next one run, silently masking the failure.

## 💡 Practical use
Chaining is used constantly in one-off administration commands typed directly into a terminal, not just inside scripts.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
