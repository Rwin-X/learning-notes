---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# curl

> curl transfers data to or from a URL, and is the standard tool for testing APIs, downloading files, and checking web service status from a script.

## Syntax
```bash
curl [-s] [-o file] [-I] url
```

## Example
```bash
$ curl -sI https://example.com | head -1
```

## Expected output
```
HTTP/2 200
```

## ⚠️ Common mistake
Forgetting -s (silent) in scripts, letting curl's progress meter clutter automated logs and output.

## 💡 Practical use
Core building block of the Website Status Checker project and any script that needs to talk to an API or web service.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
