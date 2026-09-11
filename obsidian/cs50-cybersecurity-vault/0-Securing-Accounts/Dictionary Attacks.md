---
tags: [week0, week1, attack]
---

# Dictionary Attacks

Guessing a password by trying entries from a precompiled list of likely
candidates (real words, common passwords, leaked-password lists) rather
than every possible combination. Much faster than a full
[[Brute-Force Attacks|brute-force attack]] because it exploits the fact
that humans pick predictable passwords.

Directly motivates:
- Password length/complexity requirements at [[Usernames and Passwords]]
  entry time.
- [[Hashing]] + [[Salting]] server-side, so even a stolen password
  database can't be dictionary-attacked in bulk cheaply — salting defeats
  precomputed dictionary/[[Rainbow Tables]] specifically.
- [[Password Managers]], which generate passwords with no dictionary
  structure at all.

Up: [[0 Securing Accounts MOC]] · Also relevant to [[1 Securing Data MOC]]
