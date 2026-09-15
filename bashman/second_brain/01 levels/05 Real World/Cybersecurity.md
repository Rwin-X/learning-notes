---
tags: [bash-course, real-world, level-05]
---

# Cybersecurity

Security tooling is built on Bash: parsing logs for indicators of compromise, automating repetitive parts of a penetration test workflow, and writing quick scripts to validate a hypothesis during an investigation.

## Example
```bash
grep -E "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c
```

## Notes

## Related
- [[05 Real World]]
