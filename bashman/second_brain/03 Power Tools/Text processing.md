---
tags: [bash-course, concept, level-03]
level: "[[03 Power Tools]]"
---

# Text processing

> Combining grep, cut, sort, sed, and awk in a pipeline is how most real-world text processing gets done in Bash, without writing custom code.

## Syntax
```bash
cmd1 | cmd2 | cmd3 | ...
```

## Example
```bash
$ cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

## Expected output
```
120 203.0.113.5
   87 198.51.100.2
   ...
```

## ⚠️ Common mistake
Building an overly long pipeline in one go without testing each stage — build and verify pipelines incrementally, one pipe at a time.

## 💡 Practical use
This is the core practical skill of Level 03: turning raw text (logs, output, files) into structured, useful information.

## Notes

## Related
- [[03 Power Tools]]
- [[Bash Cheat Sheet]]
