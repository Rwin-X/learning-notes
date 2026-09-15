---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Signals

> Signals are how the OS communicates with processes: SIGTERM asks for graceful shutdown, SIGKILL forces immediate termination, SIGHUP often means reload config.

## Syntax
```bash
SIGTERM (15), SIGKILL (9), SIGHUP (1), SIGINT (2)
```

## Example
```bash
$ kill -HUP 1234
```

## Expected output
```
(sends SIGHUP — many daemons reload configuration on this signal)
```

## ⚠️ Common mistake
Assuming all programs handle every signal the same way — a well-written service traps SIGTERM to clean up, but not all do.

## 💡 Practical use
Scripts can trap signals themselves (trap 'cleanup' EXIT) to guarantee cleanup code runs even if the script is interrupted.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
