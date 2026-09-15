---
tags: [bash-course, real-world, level-05]
---

# Server management

Managing a fleet of servers means running the same commands across many machines consistently — Bash scripts combined with SSH loops or tools like Ansible (which itself often shells out to Bash).

## Example
```bash
for host in $(cat servers.txt); do ssh "$host" 'uptime'; done
```

## Notes

## Related
- [[05 Real World]]
