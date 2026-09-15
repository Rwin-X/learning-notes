---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# kill

> kill sends a signal to a process by PID, most commonly to terminate it. The default signal (SIGTERM) asks the process to shut down gracefully.

## Syntax
```bash
kill [-SIGNAL] PID
```

## Example
```bash
$ kill 8842
$ kill -9 8842
```

## Expected output
```
(no output — signal sent silently)
```

## ⚠️ Common mistake
Reaching for kill -9 as the default — it force-kills immediately with no cleanup, which can corrupt data; try plain kill first.

## 💡 Practical use
Used to stop hung or misbehaving processes, restart services manually, and terminate runaway scripts during testing.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
