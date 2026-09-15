---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# ls

> ls lists the contents of a directory. Combined with flags, it can show hidden files, sizes, permissions, and modification times.

## Syntax
```bash
ls [-l] [-a] [-h] [path]
```

## Example
```bash
$ ls -lah ~/projects
```

## Expected output
```
total 12K
drwxr-xr-x 3 rwin rwin 4.0K Jan 1 12:00 .
-rw-r--r-- 1 rwin rwin  220 Jan 1 12:00 .bashrc
-rw-r--r-- 1 rwin rwin  312 Jan 1 12:00 notes.txt
```

## ⚠️ Common mistake
Forgetting -a and assuming a directory is empty when it actually contains hidden dotfiles (like .git or .env).

## 💡 Practical use
ls -la is often the very first command run when inspecting an unfamiliar server directory or investigating an incident.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
