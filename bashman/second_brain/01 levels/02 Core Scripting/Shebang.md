---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Shebang

> The shebang (#!) on the first line of a script tells the operating system which interpreter should run it, so you can execute it directly instead of typing bash first.

## Syntax
```bash
#!/bin/bash
```

## Example
```bash
$ cat deploy.sh
#!/bin/bash
echo "Deploying..."
$ chmod +x deploy.sh
$ ./deploy.sh
```

## Expected output
```
Deploying...
```

## ⚠️ Common mistake
Forgetting the shebang and then running ./script.sh directly — it may run under the wrong shell or fail with Permission denied / bad interpreter.

## 💡 Practical use
Professional scripts always start with #!/bin/bash (or #!/usr/bin/env bash for portability across systems).

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
