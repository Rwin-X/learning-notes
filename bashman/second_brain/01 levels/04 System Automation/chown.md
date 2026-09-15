---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# chown

> chown changes the owner (and optionally group) of a file or directory. It typically requires root privileges to change ownership to another user.

## Syntax
```bash
chown user:group file
```

## Example
```bash
$ sudo chown www-data:www-data /var/www/app
```

## Expected output
```
(no output — ownership updated silently)
```

## ⚠️ Common mistake
Recursively chowning (chown -R) a directory without verifying the target first, potentially breaking permissions on unrelated files.

## 💡 Practical use
Standard step when deploying web applications: files must be owned by the service user (like www-data) to be served correctly.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
