---
tags: [week0, week1, attack]
---

# Brute-Force Attacks

Trying every possible combination of characters until the correct one is
found. Exhaustive, unlike [[Dictionary Attacks]] which only tries likely
candidates. Cost grows exponentially with password length and character
set size — this is *why* length is emphasized over cleverness in password
advice.

Mitigations:
- Rate-limiting login attempts, account lockouts, CAPTCHAs (implicit
  countermeasures behind [[Authentication]] design).
- [[Two-Factor Authentication 2FA]] — even a successfully brute-forced
  password isn't enough alone.
- Server-side, slow [[Hashing]] algorithms (deliberately expensive to
  compute) make brute-forcing a stolen hash database far slower.

Up: [[0 Securing Accounts MOC]] · Also relevant to [[1 Securing Data MOC]]
