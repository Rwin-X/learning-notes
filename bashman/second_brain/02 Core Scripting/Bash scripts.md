---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Bash scripts

> A Bash script is just a text file full of commands you'd normally type one by one, saved so they can be run together, repeatedly, and automatically.

## Syntax
```bash
script.sh  (a plain text file with a .sh extension by convention)
```

## Example
```bash
$ echo 'echo Hello from a script' > hello.sh
$ bash hello.sh
```

## Expected output
```
Hello from a script
```

## ⚠️ Common mistake
Naming a file script.txt and expecting it to run as a script — the extension doesn't matter to Bash, only what's inside and how you invoke it.

## 💡 Practical use
Every piece of automation in this course, from backups to security audits, is ultimately just a script file.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
