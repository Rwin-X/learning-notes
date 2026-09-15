---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# touch

> touch creates an empty file if it doesn't exist, or updates its modification timestamp if it does.

## Syntax
```bash
touch filename
```

## Example
```bash
$ touch app.log
$ ls -l app.log
```

## Expected output
```
-rw-r--r-- 1 rwin rwin 0 Jan 1 12:00 app.log
```

## ⚠️ Common mistake
Expecting touch to add content — it only creates or timestamps a file, it never writes data into it.

## 💡 Practical use
Commonly used to create placeholder files (like .gitkeep) or to force a file's mtime for testing scripts that check timestamps.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
