---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Environment variables

> Environment variables are variables available to every process launched from your shell, not just the current script. Common ones include PATH, HOME, and USER.

## Syntax
```bash
export VAR_NAME=value
```

## Example
```bash
$ export API_ENV=production
$ echo $API_ENV
```

## Expected output
```
production
```

## ⚠️ Common mistake
Setting a variable without export and expecting a child script or program to see it — regular variables stay local to the current shell.

## 💡 Practical use
Used to pass configuration (API keys, environment names, paths) into scripts and programs without hardcoding them in files.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
