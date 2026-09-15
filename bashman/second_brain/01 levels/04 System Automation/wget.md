---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# wget

> wget downloads files from the web, with strong support for resuming interrupted downloads and recursive fetching — well suited to unattended scripts.

## Syntax
```bash
wget [-O file] url
```

## Example
```bash
$ wget -O app.tar.gz https://example.com/releases/app.tar.gz
```

## Expected output
```
app.tar.gz saved [1048576/1048576]
```

## ⚠️ Common mistake
Using wget for API interaction instead of curl — wget is built for downloading files, curl is far better suited to APIs and headers.

## 💡 Practical use
Common in deployment scripts that need to fetch a release artifact or installer as an unattended step.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
