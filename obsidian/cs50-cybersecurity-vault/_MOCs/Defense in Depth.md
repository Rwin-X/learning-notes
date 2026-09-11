---
tags: [concept, cross-cutting]
---

# Defense in Depth

No single control is assumed sufficient. Layer independent defenses so one
failure doesn't mean full compromise.

Examples built across the course:
- Account: password + [[Two-Factor Authentication 2FA]], so a leaked
  password alone isn't enough ([[Credential Stuffing]] mitigation).
- Data at rest: [[Hashing]] + [[Salting]], so even a stolen database
  doesn't yield plaintext passwords.
- Network: [[Firewall]] + [[Antivirus]] + [[Automatic Updates]], so a
  missed patch isn't the only line of defense.
- Software: [[Client-Side Validation]] *and* [[Server-Side Validation]] —
  client-side is UX, server-side is the actual security boundary, because
  client-side alone is trivially bypassed via [[Developer Tools]].

The principle connects directly to [[Threat Model]]: depth matters most
against a determined adversary willing to try multiple avenues, less
against a purely opportunistic one.
