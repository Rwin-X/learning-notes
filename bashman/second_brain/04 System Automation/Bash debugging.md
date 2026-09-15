---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Bash debugging

> Bash scripts can be debugged by tracing execution, checking syntax without running, and adding strict error-handling flags at the top of the script.

## Syntax
```bash
bash -n script.sh   # syntax check
bash -x script.sh   # trace execution
```

## Example
```bash
$ bash -x deploy.sh
```

## Expected output
```
+ echo 'Deploying...'
Deploying...
+ cp app.tar.gz /releases/
```

## ⚠️ Common mistake
Debugging a complex script purely by adding echo statements everywhere instead of using bash -x, which shows every command as it executes.

## 💡 Practical use
Essential skill before trusting any script in production — tracing execution reveals exactly where and why something went wrong.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
