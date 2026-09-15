---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# Bash vs other shells

> sh is the original, minimal POSIX shell. Bash extends it with more features (arrays, [[ ]], string manipulation). zsh and fish add further conveniences but aren't always installed by default on servers.

## Syntax
```bash
#!/bin/bash    vs    #!/bin/sh
```

## Example
```bash
$ ls -l /bin/sh
```

## Expected output
```
lrwxrwxrwx 1 root root 4 Jan 1 00:00 /bin/sh -> dash
```

## ⚠️ Common mistake
Writing a script with #!/bin/bash features but a #!/bin/sh shebang — it may silently break on systems where /bin/sh is dash, not bash.

## 💡 Practical use
Servers and Docker containers often only have /bin/sh. Knowing the difference prevents "works on my machine" bugs.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
