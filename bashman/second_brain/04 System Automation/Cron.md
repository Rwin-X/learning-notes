---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Cron

> cron runs scheduled commands automatically at specified times, defined in a crontab file using a five-field time syntax.

## Syntax
```bash
min hour day month weekday command
```

## Example
```bash
$ crontab -l
0 2 * * * /home/rwin/backup.sh
```

## Expected output
```
(runs backup.sh every day at 2:00 AM)
```

## ⚠️ Common mistake
Forgetting that cron jobs run with a minimal environment (no PATH, no user profile loaded) — always use absolute paths in cron scripts.

## 💡 Practical use
The standard mechanism for scheduled automation: nightly backups, log rotation, health checks, and periodic report generation.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
