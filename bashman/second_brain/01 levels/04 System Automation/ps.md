---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# ps

> ps lists running processes. ps aux is the most common form, showing all processes system-wide with owner, CPU, and memory usage.

## Syntax
```bash
ps aux
ps aux | grep name
```

## Example
```bash
$ ps aux | grep python
```

## Expected output
```
rwin  2201  1.2  0.8  python3 app.py
```

## ⚠️ Common mistake
Forgetting that grep pattern itself shows up as a matching process in the output — filter it out with grep -v grep if it matters.

## 💡 Practical use
The starting point for any "what's running on this system" investigation, whether debugging or checking for unauthorized processes.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
