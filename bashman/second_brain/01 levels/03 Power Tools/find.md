---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# find

> find searches the filesystem for files and directories matching criteria like name, type, size, or modification time.

## Syntax
```bash
find path -name "pattern" [-type f|d]
```

## Example
```bash
$ find /var/log -name "*.log" -mtime -1
```

## Expected output
```
/var/log/syslog
/var/log/auth.log
```

## ⚠️ Common mistake
Forgetting to quote the pattern (-name *.log without quotes), letting the shell expand the glob before find ever sees it.

## 💡 Practical use
Used to locate config files, find recently modified files during an investigation, or clean up old temp files by age.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
