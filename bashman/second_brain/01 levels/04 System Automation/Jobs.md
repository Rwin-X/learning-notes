---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Jobs

> jobs lists background and suspended processes started from the current shell session, along with their job numbers.

## Syntax
```bash
jobs
fg %1
bg %1
```

## Example
```bash
$ jobs
```

## Expected output
```
[1]+  Running   ./long_task.sh &
```

## ⚠️ Common mistake
Confusing a job number (%1) with a PID — they're different identifiers; fg %1 brings job 1 to the foreground, not process 1.

## 💡 Practical use
Useful for managing multiple background tasks within a single interactive terminal session during manual administration.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
