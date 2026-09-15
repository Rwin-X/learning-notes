---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# until

> until is the inverse of while — it runs the block until a condition becomes true, i.e. while it's still false.

## Syntax
```bash
until [ condition ]; do
  commands
done
```

## Example
```bash
$ n=1
$ until [ "$n" -gt 3 ]; do echo "n=$n"; n=$((n+1)); done
```

## Expected output
```
n=1
n=2
n=3
```

## ⚠️ Common mistake
Confusing until's logic with while and ending up with a loop condition backwards from what was intended.

## 💡 Practical use
Useful for "wait until service is ready" style polling loops, e.g. until curl -s localhost:8080 > /dev/null; do sleep 1; done.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
