---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# awk

> awk is a full pattern-scanning and text-processing language, most often used to extract and compute values from column-based data.

## Syntax
```bash
awk '{ print $1, $3 }' file
```

## Example
```bash
$ awk '{sum += $2} END {print sum}' sales.txt
```

## Expected output
```
18450
```

## ⚠️ Common mistake
Forgetting that awk fields are whitespace-separated by default — use -F to set a different delimiter, like awk -F, for CSV files.

## 💡 Practical use
Extremely common in log analysis: summing bytes transferred, extracting specific columns, or computing averages from data files.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
