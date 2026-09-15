---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Automation

> Automation means encoding a repeatable manual process into a script so it runs identically every time, without human error or fatigue.

## Syntax
```bash
script.sh + cron/CI trigger = automation
```

## Example
```bash
$ crontab -e
0 3 * * * /home/rwin/scripts/full_backup.sh
```

## Expected output
```
(the backup now runs unattended every night at 3 AM)
```

## ⚠️ Common mistake
Automating a process before it's been run and verified manually several times — automate proven, understood procedures, not guesses.

## 💡 Practical use
The overarching goal of Levels 02–04: everything you've learned combines here into scripts that run themselves, reliably.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
