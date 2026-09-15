---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# grep

> grep searches text for lines matching a pattern, and is one of the most-used commands in all of Linux administration and security work.

## Syntax
```bash
grep [-i] [-r] [-n] "pattern" file
```

## Example
```bash
$ grep -in "error" app.log
```

## Expected output
```
42:2026-08-16 ERROR: connection refused
107:2026-08-16 Error: timeout
```

## ⚠️ Common mistake
Forgetting -i when the case of the search term is inconsistent in the file, silently missing matches like Error vs error.

## 💡 Practical use
The default first move when investigating logs: grep for error, failed, or a specific IP address across log files.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
