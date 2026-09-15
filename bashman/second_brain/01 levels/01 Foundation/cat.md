---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# cat

> cat prints the entire contents of one or more files to the screen. It's also used to concatenate multiple files together.

## Syntax
```bash
cat file1 [file2 ...]
```

## Example
```bash
$ cat notes.txt
```

## Expected output
```
Meeting at 10am
Bring the report
```

## ⚠️ Common mistake
Using cat on a huge file (like a gigabyte log) and flooding your terminal — use less or head/tail instead.

## 💡 Practical use
Quick way to inspect small config files and combine multiple files into one, e.g. cat part1.log part2.log > full.log.

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
