---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# Regular expressions

> Regular expressions (regex) describe text patterns to match, using metacharacters like . * ^ $ [ ] to represent flexible rules rather than exact text.

## Syntax
```bash
^start   end$   .   *   [0-9]+   \d
```

## Example
```bash
$ grep -E "^[0-9]{3}-[0-9]{4}$" contacts.txt
```

## Expected output
```
555-1234
```

## ⚠️ Common mistake
Forgetting to escape special characters like . (which matches any character) when a literal dot was intended — use \. instead.

## 💡 Practical use
Regex powers grep, sed, and awk pattern matching, and is essential for validating input formats and parsing structured logs.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
