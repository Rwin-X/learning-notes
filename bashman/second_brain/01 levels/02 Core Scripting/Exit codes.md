---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Exit codes

> Every command returns an exit code when it finishes: 0 means success, any non-zero value means some kind of failure, with meanings often specific to the command.

## Syntax
```bash
exit N   (0 = success, 1-255 = failure)
```

## Example
```bash
$ ls /nonexistent; echo "exit code: $?"
```

## Expected output
```
ls: cannot access '/nonexistent': No such file or directory
exit code: 2
```

## ⚠️ Common mistake
Assuming a command succeeded just because it produced output — always check $? or use if for commands where failure matters.

## 💡 Practical use
Automation and CI/CD pipelines rely entirely on exit codes to decide whether to continue, retry, or abort a process.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
