---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# File permissions

> Every file has three permission sets — owner, group, others — each with read, write, and execute bits, shown as rwx in ls -l output.

## Syntax
```bash
-rwxr-xr--   (owner: rwx, group: r-x, others: r--)
```

## Example
```bash
$ ls -l deploy.sh
```

## Expected output
```
-rwxr-xr-x 1 rwin rwin 512 Jan 1 12:00 deploy.sh
```

## ⚠️ Common mistake
Assuming a script will run just because it exists — without execute permission, ./script.sh fails with Permission denied.

## 💡 Practical use
Understanding permission strings at a glance is essential for both administration and spotting misconfigurations in security audits.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
