---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# tr

> tr translates or deletes individual characters from input — useful for case conversion, removing characters, or squeezing repeats.

## Syntax
```bash
tr 'set1' 'set2'
tr -d 'characters'
```

## Example
```bash
$ echo "Hello World" | tr 'a-z' 'A-Z'
```

## Expected output
```
HELLO WORLD
```

## ⚠️ Common mistake
Trying to use tr for multi-character string replacement — it only maps single characters, not substrings; that's sed's job.

## 💡 Practical use
Handy for quick case conversion, stripping carriage returns from Windows-formatted files (tr -d '\r'), and cleaning input.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
