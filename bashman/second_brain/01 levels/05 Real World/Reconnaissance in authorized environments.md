---
tags: [bash-course, real-world, level-05]
---

# Reconnaissance in authorized environments

In authorized security assessments, Bash automates the tedious first steps of recon — enumerating open ports, resolving hostnames, checking service banners — always strictly within the scope you have permission to test.

## Example
```bash
for port in 22 80 443; do nc -zv -w1 target.local $port; done
```

## Notes

## Related
- [[05 Real World]]
