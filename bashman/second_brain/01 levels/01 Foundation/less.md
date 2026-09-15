---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# less

> less opens a file for scrollable, searchable viewing without loading the whole thing into your terminal at once — ideal for large files.

## Syntax
```bash
less filename
```

## Example
```bash
$ less /var/log/syslog
```

## Expected output
```
(interactive viewer — use arrows to scroll, / to search, q to quit)
```

## ⚠️ Common mistake
Forgetting how to exit — press q, not Ctrl+C, which can leave the terminal in a strange state.

## 💡 Practical use
The standard tool for reading large log files on a server without overwhelming your terminal or SSH connection.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
