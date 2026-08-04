---
type: moc
tags: [moc, ctf]
---

# CTF & Labs MOC

## By Platform
### HackTheBox
```dataview
LIST
FROM #ctf AND #htb
SORT date_solved DESC
```

### TryHackMe
```dataview
LIST
FROM #ctf AND #thm
SORT date_solved DESC
```

### Other
```dataview
LIST
FROM #ctf
WHERE !contains(tags, "htb") AND !contains(tags, "thm")
SORT date_solved DESC
```

## Skill Coverage Tracker
Use this to see where your practical reps are thin.

| Category | Count | Last Practiced |
|---|---|---|
| Web | | |
| Network | | |
| Privesc (Linux) | | |
| Privesc (Windows) | | |
| Crypto | | |
| Forensics | | |
| Reversing | | |

## Related
- [[CEH MOC]]
- [[Web AppSec MOC]]
