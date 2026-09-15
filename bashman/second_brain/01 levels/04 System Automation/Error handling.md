---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Error handling

> Bash scripts should explicitly handle failure — checking exit codes, using set -e to stop on errors, and cleaning up with trap when things go wrong.

## Syntax
```bash
set -euo pipefail
trap 'cleanup' EXIT
```

## Example
```bash
$ cat safe.sh
#!/bin/bash
set -euo pipefail
cp missing.txt backup/
```

## Expected output
```
cp: cannot stat 'missing.txt': No such file or directory
(script exits immediately due to set -e)
```

## ⚠️ Common mistake
Writing scripts with no error handling at all, where one failed command midway lets the rest of the script continue on a broken state.

## 💡 Practical use
set -euo pipefail at the top of every serious script is considered a baseline professional habit, not an optional extra.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
