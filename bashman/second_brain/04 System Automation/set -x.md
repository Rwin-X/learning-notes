---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# set -x

> set -x turns on command tracing inside a running script, printing each command (with expanded variables) before it executes — and set +x turns it back off.

## Syntax
```bash
set -x
... commands to trace ...
set +x
```

## Example
```bash
$ cat trace.sh
#!/bin/bash
set -x
name="Rwin"
echo "Hi $name"
set +x
```

## Expected output
```
+ name=Rwin
+ echo 'Hi Rwin'
Hi Rwin
```

## ⚠️ Common mistake
Leaving set -x enabled in production scripts, which can leak sensitive variable values (like API keys) into logs.

## 💡 Practical use
Ideal for isolating exactly which section of a long script is misbehaving, without rewriting the whole thing with -x.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
