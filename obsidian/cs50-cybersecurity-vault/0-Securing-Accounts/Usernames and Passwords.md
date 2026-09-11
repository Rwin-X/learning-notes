
---
tags: [week0, concept]
---

# Usernames and Passwords

The baseline [[Authentication]] mechanism: a public-ish identifier
(username) paired with a secret (password) only the legitimate user
should know.

Weaknesses that motivate the rest of the week:
- Predictable/short passwords fall to [[Dictionary Attacks]] and
  [[Brute-Force Attacks]].
- Reused passwords across sites enable [[Credential Stuffing]] once one
  site is breached.
- Passwords can be captured directly via [[Keylogging]] or
  [[Phishing]], bypassing strength entirely — a strong password doesn't
  help if it's handed over voluntarily.

How they're actually stored server-side (never in plaintext, ideally)
is covered in [[Hashing]] and [[Salting]] (Week 1).

Mitigations: [[Password Managers]] (unique, strong passwords per site),
[[Two-Factor Authentication 2FA]] (password alone isn't enough), and
eventually [[Passkeys]] (removing the shared secret model altogether).

Up: [[0 Securing Accounts MOC]]
