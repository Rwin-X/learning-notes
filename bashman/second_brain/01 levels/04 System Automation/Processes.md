---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Processes

> A process is a running instance of a program, identified by a unique PID (process ID). Every command you run becomes a process while active.

## Syntax
```bash
PID, PPID (parent process ID)
```

## Example
```bash
$ echo $$
```

## Expected output
```
8842
```

## ⚠️ Common mistake
Assuming a killed process is instantly gone — some processes ignore signals or take time to clean up and exit.

## 💡 Practical use
Process awareness underlies monitoring, debugging hung applications, and identifying suspicious activity during incident response.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
