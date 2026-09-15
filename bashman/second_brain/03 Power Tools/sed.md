---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# sed

> sed is a stream editor that transforms text line by line, most commonly used for find-and-replace directly in files or piped streams.

## Syntax
```bash
sed 's/old/new/g' file
```

## Example
```bash
$ sed -i 's/DEBUG/INFO/g' app.log
```

## Expected output
```
(file is edited in place — DEBUG replaced with INFO throughout)
```

## ⚠️ Common mistake
Forgetting -i when the intent is to edit the file in place — without it, sed only prints the changed result to the screen.

## 💡 Practical use
Used in deployment scripts to swap config values (environment names, version numbers) across files automatically.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
