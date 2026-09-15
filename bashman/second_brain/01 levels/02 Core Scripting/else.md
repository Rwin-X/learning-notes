---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# else

> else defines the fallback block that runs when none of the preceding if/elif conditions were true.

## Syntax
```bash
if [ condition ]; then
  ...
else
  ...
fi
```

## Example
```bash
$ if [ -f "config.yaml" ]; then echo "found"; else echo "missing, using defaults"; fi
```

## Expected output
```
missing, using defaults
```

## ⚠️ Common mistake
Leaving out else in scripts that need a default fallback, causing silent failures when no condition matches.

## 💡 Practical use
Used to define safe defaults — e.g. falling back to a default config or exiting cleanly when a required file is missing.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
