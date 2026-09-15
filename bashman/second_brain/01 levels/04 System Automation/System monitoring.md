---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# System monitoring

> System monitoring means regularly checking resource usage — CPU, memory, disk, network — to catch problems before they cause outages.

## Syntax
```bash
df -h, free -h, uptime, vmstat
```

## Example
```bash
$ df -h /
```

## Expected output
```
Filesystem  Size  Used Avail Use% Mounted on
/dev/sda1    40G   28G   10G  74% /
```

## ⚠️ Common mistake
Checking system health manually and inconsistently instead of scripting it — manual checks get skipped exactly when they matter most.

## 💡 Practical use
The basis for the Disk Usage Monitor and Server Health Monitor projects later in this course.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
