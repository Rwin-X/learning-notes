---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Logs

> Logs are timestamped records of what a system or application did, typically stored under /var/log, and are the primary evidence trail for debugging and investigations.

## Syntax
```bash
/var/log/syslog, /var/log/auth.log, journalctl
```

## Example
```bash
$ tail -20 /var/log/auth.log
```

## Expected output
```
Aug 16 10:02:11 host sshd[203]: Accepted publickey for rwin
```

## ⚠️ Common mistake
Not rotating logs, letting them grow unbounded until they fill the disk — logrotate exists specifically to prevent this.

## 💡 Practical use
Central to the Log Analyzer project and to real-world incident response, where logs are often the only record of what happened.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
