---
tags: [bash-course, real-world, level-05]
---

# Incident response

When something goes wrong, responders use Bash to rapidly gather evidence — running processes, open network connections, recent logins — before it disappears or the system is taken offline.

## Example
```bash
ps aux; who; ss -tunp; last -20 > incident_snapshot.txt
```

## Notes

## Related
- [[05 Real World]]
