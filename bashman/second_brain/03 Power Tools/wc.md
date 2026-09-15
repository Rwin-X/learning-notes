---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# wc

> wc counts lines, words, and characters/bytes in text. -l for lines is the most commonly used flag.

## Syntax
```bash
wc [-l] [-w] [-c] file
```

## Example
```bash
$ wc -l /etc/passwd
```

## Expected output
```
42 /etc/passwd
```

## ⚠️ Common mistake
Forgetting that wc -l counts newline characters, so a file missing a trailing newline may report one line fewer than expected.

## 💡 Practical use
Used constantly to quickly check log file sizes, count matching lines from a grep, or count items in a list.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
