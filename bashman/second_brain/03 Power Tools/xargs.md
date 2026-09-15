---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# xargs

> xargs builds and runs commands using input from another command's output, useful for commands that don't accept piped input directly.

## Syntax
```bash
command1 | xargs command2
```

## Example
```bash
$ find . -name "*.tmp" | xargs rm -f
```

## Expected output
```
(deletes every matched .tmp file)
```

## ⚠️ Common mistake
Running destructive commands like rm through xargs without testing with echo first — always dry-run with xargs echo before xargs rm.

## 💡 Practical use
The standard way to apply an action (delete, chmod, grep) to every result of a find or grep search in one line.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
