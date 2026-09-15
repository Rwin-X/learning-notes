---
tags: [bash-course, real-world, level-05]
---

# Log analysis

Security and ops teams alike depend on grep, awk, and sort to turn raw log noise into a short list of what actually matters, long before reaching for a dedicated SIEM tool.

## Example
```bash
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

## Notes

## Related
- [[05 Real World]]
