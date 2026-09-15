---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# sort

> sort arranges lines of text alphabetically or numerically. -n sorts numerically, -r reverses the order.

## Syntax
```bash
sort [-n] [-r] [-k N] file
```

## Example
```bash
$ sort -n scores.txt
```

## Expected output
```
3
17
42
108
```

## ⚠️ Common mistake
Sorting numbers without -n and getting alphabetical order instead — "108" sorts before "17" as plain text.

## 💡 Practical use
Commonly chained with uniq -c to rank the most frequent values in log files, like top requesting IP addresses.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
