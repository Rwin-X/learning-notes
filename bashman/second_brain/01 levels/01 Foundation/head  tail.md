---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# head / tail

> head shows the first lines of a file (default 10); tail shows the last lines. tail -f follows a file live as new lines are appended.

## Syntax
```bash
head [-n N] file
tail [-n N] [-f] file
```

## Example
```bash
$ tail -n 5 -f /var/log/app.log
```

## Expected output
```
[12:01:03] request handled
[12:01:04] request handled
(...live updates as new lines arrive, Ctrl+C to stop)
```

## ⚠️ Common mistake
Using tail -f on a rotated log file and not noticing it stopped following after the file was replaced — a common production gotcha.

## 💡 Practical use
tail -f is one of the most-used commands in live debugging: watching an application's log in real time as it runs.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
