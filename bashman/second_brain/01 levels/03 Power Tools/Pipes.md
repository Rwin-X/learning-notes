---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# Pipes

> The pipe (|) sends the output of one command directly into the input of the next, letting you chain small tools into a larger operation.

## Syntax
```bash
command1 | command2
```

## Example
```bash
$ ps aux | grep nginx
```

## Expected output
```
rwin  1423  0.0  0.2  nginx: worker process
```

## ⚠️ Common mistake
Piping a command that produces no output and expecting the next command in the chain to magically produce something — garbage in, garbage out.

## 💡 Practical use
The core Unix philosophy in action: combine simple, single-purpose tools to build powerful one-liners without writing a script.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
