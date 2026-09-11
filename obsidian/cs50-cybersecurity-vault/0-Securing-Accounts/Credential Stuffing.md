---
tags: [week0, attack]
---

# Credential Stuffing

Taking username/password pairs leaked from one breached site and trying
them against *other* sites, betting on password reuse. Doesn't require
guessing or cracking anything — it exploits human behavior, not a
technical weakness in any single system.

Directly motivates:
- Unique passwords per site — practically requires [[Password Managers]].
- [[Two-Factor Authentication 2FA]], so a stuffed credential alone still
  fails.
- Why breached-database hashing quality ([[Hashing]], [[Salting]])
  matters to *every other site* the user reused a password on, not just
  the breached one.

Up: [[0 Securing Accounts MOC]]
