---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# cp

> cp copies files or directories. Use -r (recursive) to copy an entire directory tree.

## Syntax
```bash
cp [-r] source destination
```

## Example
```bash
$ cp config.yaml config.yaml.bak
$ cp -r src/ src_backup/
```

## Expected output
```
(no output — success is silent)
```

## ⚠️ Common mistake
Forgetting -r when copying a directory, resulting in: cp: -r not specified; omitting directory 'src/'.

## 💡 Practical use
Standard first step before editing a config file on a live server: always cp the original before you touch it.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
