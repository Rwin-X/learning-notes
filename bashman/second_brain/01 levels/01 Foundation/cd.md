---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# cd

> cd changes your current working directory. Used with no arguments, it takes you to your home directory.

## Syntax
```bash
cd [path]
```

## Example
```bash
$ cd /var/log
$ pwd
```

## Expected output
```
/var/log
```

## ⚠️ Common mistake
Using cd with a relative path from the wrong location, landing you somewhere unintended — always pwd if unsure.

## 💡 Practical use
cd - jumps back to your previous directory; cd .. goes up one level. Both are used constantly in real workflows.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
