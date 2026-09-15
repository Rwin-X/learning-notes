---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# for

> for loops iterate over a list of items — words, filenames, numbers, or command output — running commands once per item.

## Syntax
```bash
for item in list; do
  commands
done
```

## Example
```bash
$ for file in *.log; do echo "Found: $file"; done
```

## Expected output
```
Found: app.log
Found: error.log
```

## ⚠️ Common mistake
Looping over ls output directly (for f in $(ls)) instead of using globs — this breaks on filenames with spaces. Prefer for f in *.

## 💡 Practical use
Used to process batches of files, iterate over server lists, or repeat a task a fixed number of times.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
