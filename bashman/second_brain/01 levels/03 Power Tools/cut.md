---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# cut

> cut extracts specific columns or fields from each line of text, based on a delimiter or fixed character positions.

## Syntax
```bash
cut -d"delimiter" -f field_number file
```

## Example
```bash
$ cut -d: -f1 /etc/passwd | head -3
```

## Expected output
```
root
daemon
bin
```

## ⚠️ Common mistake
Assuming the delimiter is always whitespace by default — cut requires -d to specify it explicitly for anything other than tabs.

## 💡 Practical use
Used to pull specific fields out of structured log lines, CSVs, or config files like /etc/passwd.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
