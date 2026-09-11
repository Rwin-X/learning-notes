[Authorization.md](https://github.com/user-attachments/files/32103842/Authorization.md)
---
tags: [week0, concept]
---

# Authorization

What an already-[[Authentication|authenticated]] identity is *permitted*
to do or access. Login proves who you are; authorization decides what you
can touch.

Failure mode to watch for: systems that check authentication once and
never re-check authorization per action/resource — a common root cause of
real-world breaches, and conceptually related to why
[[Server-Side Validation]] matters in Week 3 (never trust the client to
self-enforce permissions).

Up: [[0 Securing Accounts MOC]]
