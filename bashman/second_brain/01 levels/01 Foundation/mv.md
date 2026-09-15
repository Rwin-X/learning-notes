---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# mv

> mv moves files or directories, and is also how you rename something in Bash — there is no separate rename command.

## Syntax
```bash
mv source destination
```

## Example
```bash
$ mv draft.txt final.txt
```

## Expected output
```
(no output — success is silent)
```

## ⚠️ Common mistake
Running mv into an existing filename and silently overwriting it with no confirmation — always check the destination first.

## 💡 Practical use
Used both for organizing files and for atomic-style deployments (e.g. mv new_build/ live/ swaps a directory instantly).

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
