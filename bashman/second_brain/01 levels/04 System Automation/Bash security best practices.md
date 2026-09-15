---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Bash security best practices

> Writing secure Bash means quoting variables, validating input, avoiding eval on untrusted data, and using least-privilege permissions throughout.

## Syntax
```bash
quote variables, validate input, avoid eval, chmod 600 secrets
```

## Example
```bash
$ chmod 600 .env
$ if [[ "$input" =~ ^[a-zA-Z0-9_]+$ ]]; then process "$input"; fi
```

## Expected output
```
(only alphanumeric/underscore input is accepted and processed)
```

## ⚠️ Common mistake
Using eval on any input that came from a user or external source — this can allow arbitrary command execution if the input is crafted maliciously.

## 💡 Practical use
Directly relevant to cybersecurity work: scripts you write for security tooling must themselves be free of the vulnerabilities they look for.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
