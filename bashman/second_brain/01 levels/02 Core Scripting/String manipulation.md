---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# String manipulation

> Bash supports built-in string operations for length, substrings, and replacement without needing external tools for simple cases.

## Syntax
```bash
${#str}          # length
${str:0:3}       # substring
${str/old/new}   # replace
```

## Example
```bash
$ file="report.txt"
$ echo "${file%.txt}"
$ echo "${file/report/summary}"
```

## Expected output
```
report
summary.txt
```

## ⚠️ Common mistake
Reaching for sed or awk for a simple substring or replace operation that Bash's own parameter expansion already handles faster.

## 💡 Practical use
Frequently used for stripping file extensions, building filenames dynamically, and cleaning up variable values.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
