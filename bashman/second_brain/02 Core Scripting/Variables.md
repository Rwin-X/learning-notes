---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Variables

> Variables store values you can reuse. Bash variables have no type declaration and no spaces around the = sign.

## Syntax
```bash
name=value
echo $name
```

## Example
```bash
$ name="Rwin"
$ echo "Hello, $name"
```

## Expected output
```
Hello, Rwin
```

## ⚠️ Common mistake
Writing name = "Rwin" with spaces around = — Bash interprets this as running a command called name with arguments, not an assignment.

## 💡 Practical use
Variables let scripts adapt to different inputs instead of hardcoding values — the foundation of every reusable script.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
