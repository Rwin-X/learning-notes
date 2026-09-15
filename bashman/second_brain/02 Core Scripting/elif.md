---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# elif

> elif lets you check additional conditions if the first if was false, avoiding deeply nested if statements.

## Syntax
```bash
if [ cond1 ]; then
  ...
elif [ cond2 ]; then
  ...
fi
```

## Example
```bash
$ score=72
$ if [ "$score" -ge 90 ]; then echo A
elif [ "$score" -ge 70 ]; then echo B
else echo C; fi
```

## Expected output
```
B
```

## ⚠️ Common mistake
Chaining too many elif blocks when a case statement would be clearer and easier to maintain.

## 💡 Practical use
Common in scripts that classify system state: disk usage thresholds, response codes, severity levels in log analysis.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
