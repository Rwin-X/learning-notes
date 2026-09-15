---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# uniq

> uniq removes adjacent duplicate lines. It only works correctly on sorted input, so it's almost always paired with sort first.

## Syntax
```bash
sort file | uniq [-c]
```

## Example
```bash
$ sort visitors.txt | uniq -c | sort -rn
```

## Expected output
```
15 192.168.1.10
   8 192.168.1.22
   2 10.0.0.5
```

## ⚠️ Common mistake
Running uniq on unsorted data and being confused that obvious duplicates aren't removed — uniq only compares neighboring lines.

## 💡 Practical use
The classic sort | uniq -c | sort -rn pipeline is the standard way to count and rank frequency in any text dataset.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
