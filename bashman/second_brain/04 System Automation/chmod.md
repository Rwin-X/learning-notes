---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# chmod

> chmod changes a file's permissions, either symbolically (u+x) or numerically (755), where each digit represents owner/group/others.

## Syntax
```bash
chmod [ugo][+-=][rwx] file
chmod 755 file
```

## Example
```bash
$ chmod +x deploy.sh
$ chmod 644 config.yaml
```

## Expected output
```
(no output — permissions updated silently)
```

## ⚠️ Common mistake
Using chmod 777 as a lazy fix for permission errors — this grants full read/write/execute to everyone, a serious security risk.

## 💡 Practical use
Used to make scripts executable, lock down sensitive config files (600) so only the owner can read them, and enforce least privilege.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
