---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Arithmetic

> Bash performs integer arithmetic using $((...)) or the let builtin. It doesn't handle decimals natively — that requires external tools like bc or awk.

## Syntax
```bash
result=$((expression))
```

## Example
```bash
$ a=7
$ b=3
$ echo $((a + b))
$ echo $((a % b))
```

## Expected output
```
10
1
```

## ⚠️ Common mistake
Expecting decimal precision from $(( )) — echo $((10/3)) gives 3, not 3.33, because Bash arithmetic is integer-only.

## 💡 Practical use
Used for counters in loops, calculating percentages for monitoring scripts, and simple numeric validation.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
