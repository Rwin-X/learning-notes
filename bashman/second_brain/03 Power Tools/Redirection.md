---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# Redirection

> Redirection sends command output to a file (>) or appends to it (>>) instead of the screen, and can also feed a file in as input (<).

## Syntax
```bash
command > file    # overwrite
command >> file   # append
command < file    # input
```

## Example
```bash
$ echo "deploy started" >> deploy.log
```

## Expected output
```
(no screen output — text is appended to deploy.log)
```

## ⚠️ Common mistake
Using > instead of >> and unintentionally wiping out an existing log file's entire history with a single command.

## 💡 Practical use
Essential for logging script output: ./backup.sh > backup.log 2>&1 captures both normal output and errors into one file.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
