---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Command substitution

> Command substitution runs a command and captures its output into a variable or string, using $(...).

## Syntax
```bash
result=$(command)
```

## Example
```bash
$ today=$(date +%Y-%m-%d)
$ echo "Today is $today"
```

## Expected output
```
Today is 2026-08-16
```

## ⚠️ Common mistake
Using old-style backticks `command` nested inside another substitution — $() nests cleanly, backticks do not.

## 💡 Practical use
Essential for scripts that need live system data: current date, hostname, disk usage, process counts, and more.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
