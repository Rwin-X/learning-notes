---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# Linux filesystem

> Linux has a single unified directory tree starting at / (root). Everything — disks, devices, configs — lives somewhere under it. There's no C:\ style drive letters.

## Syntax
```bash
/  →  /home  /etc  /var  /usr  /bin  /tmp
```

## Example
```bash
$ ls /
```

## Expected output
```
bin  boot  etc  home  lib  proc  root  tmp  usr  var
```

## ⚠️ Common mistake
Assuming Windows-style paths (C:\Users\...) — Linux paths use forward slashes and are case-sensitive.

## 💡 Practical use
Knowing where things live (/etc for config, /var/log for logs, /tmp for scratch space) is essential for both admin and security work.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
