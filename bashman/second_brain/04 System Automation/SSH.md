---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# SSH

> SSH provides encrypted remote access to another machine's shell, and underlies most remote administration and automation workflows.

## Syntax
```bash
ssh user@host
ssh user@host 'remote-command'
```

## Example
```bash
$ ssh rwin@server.local 'uptime'
```

## Expected output
```
12:04:01 up 14 days,  2:31,  1 user,  load average: 0.08, 0.05, 0.01
```

## ⚠️ Common mistake
Using password authentication in automated scripts — key-based authentication is required for any non-interactive SSH automation.

## 💡 Practical use
The backbone of remote server administration: running commands, copying files (via scp), and orchestrating deployments across machines.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
