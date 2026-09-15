---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# top

> top shows a live, auto-refreshing view of running processes ranked by resource usage — the go-to tool for real-time system monitoring.

## Syntax
```bash
top
```

## Example
```bash
$ top
```

## Expected output
```
(interactive live view — press q to quit, P to sort by CPU, M by memory)
```

## ⚠️ Common mistake
Leaving top running in an automated script's output — it's an interactive tool; for scripting, use ps or top -bn1 instead.

## 💡 Practical use
First command to run when a server feels slow: instantly reveals which process is consuming CPU or memory.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
