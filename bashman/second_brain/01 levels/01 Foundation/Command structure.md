---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# Command structure

> Most Unix commands share a predictable shape: the command itself, single or double-dash flags to modify behavior, and arguments telling it what to act on.

## Syntax
```bash
cmd -x --long-flag argument1 argument2
```

## Example
```bash
$ ls -la /home
```

## Expected output
```
drwxr-xr-x  4 root root 4096 Jan 1 00:00 .
drwxr-xr-x 20 root root 4096 Jan 1 00:00 ..
drwxr-xr-x  6 rwin rwin 4096 Jan 1 00:00 rwin
```

## ⚠️ Common mistake
Putting a space where none is expected, like - la instead of -la, which Bash reads as two separate (and likely invalid) arguments.

## 💡 Practical use
Reading unfamiliar commands in scripts becomes far easier once you can mentally parse: command / flags / targets.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
