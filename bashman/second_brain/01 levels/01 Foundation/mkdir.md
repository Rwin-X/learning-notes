---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# mkdir

> mkdir creates new directories. The -p flag creates any missing parent directories along the way instead of erroring out.

## Syntax
```bash
mkdir [-p] directory-name
```

## Example
```bash
$ mkdir -p project/src/utils
```

## Expected output
```
(no output — success is silent)
```

## ⚠️ Common mistake
Forgetting -p when creating a nested path and getting: mkdir: cannot create directory 'a/b': No such file or directory.

## 💡 Practical use
Used at the start of nearly every project-setup or deployment script to scaffold a directory structure.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
