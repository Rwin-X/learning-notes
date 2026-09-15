---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Users and groups

> Linux organizes access control around users and groups. Every process runs as a user, and group membership grants shared access to resources.

## Syntax
```bash
useradd, usermod -aG group user, groups user
```

## Example
```bash
$ groups rwin
```

## Expected output
```
rwin : rwin sudo docker
```

## ⚠️ Common mistake
Adding a user to a group with usermod and expecting it to apply immediately — the user typically needs to log out and back in.

## 💡 Practical use
Understanding user/group structure is fundamental to both server administration and privilege-escalation-focused security review.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
