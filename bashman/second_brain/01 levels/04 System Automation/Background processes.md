---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Background processes

> Appending & runs a command in the background, returning control of the terminal immediately instead of waiting for it to finish.

## Syntax
```bash
command &
```

## Example
```bash
$ ./long_task.sh &
[1] 9012
```

## Expected output
```
[1] 9012
```

## ⚠️ Common mistake
Closing the terminal session and assuming background jobs keep running — without nohup or disown, they may be killed with the shell.

## 💡 Practical use
Used to launch long-running scripts (backups, monitors) without blocking further terminal use.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
