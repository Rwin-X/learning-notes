---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# File tests

> File test operators check properties of a file or directory — whether it exists, is readable, is a directory, etc. — before acting on it.

## Syntax
```bash
[ -f file ]   # is a regular file
[ -d dir ]    # is a directory
[ -r file ]   # is readable
[ -x file ]   # is executable
```

## Example
```bash
$ if [ -f "config.yaml" ]; then echo "config exists"; fi
```

## Expected output
```
config exists
```

## ⚠️ Common mistake
Skipping file existence checks before reading or writing, causing scripts to crash on missing files instead of failing gracefully.

## 💡 Practical use
Standard defensive pattern at the top of production scripts: verify required files and directories exist before doing real work.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
