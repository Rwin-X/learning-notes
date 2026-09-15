---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# rm

> rm permanently deletes files. There is no trash bin — deleted means gone. -r deletes directories recursively, -f forces deletion without prompts.

## Syntax
```bash
rm [-r] [-f] target
```

## Example
```bash
$ rm old_log.txt
$ rm -rf temp_build/
```

## Expected output
```
(no output — success is silent, and irreversible)
```

## ⚠️ Common mistake
Running rm -rf with a wrong or empty variable, e.g. rm -rf $DIR/ when $DIR is unset, which can delete far more than intended.

## 💡 Practical use
Because rm is irreversible, professional scripts always double-check the target path (and often prompt) before deleting anything.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
