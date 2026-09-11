---
tags: [week0, concept, defense]
aliases: [2FA]
---

# Two-Factor Authentication (2FA)

Requires two *different categories* of proof before granting access —
not just two passwords, but two different factor types. See
[[Multi-Factor Authentication Factors]] for the three categories
(knowledge, possession, inherence).

Directly defeats attacks that only compromise one factor:
- A [[Phishing]]-stolen or [[Keylogging]]-captured password alone no
  longer grants access without the second factor.
- [[Credential Stuffing]] from a breached, reused password fails the
  same way.

Common second factor: a code from an app or SMS — see [[One-Time Password OTP]].
Weakness: if the second factor is SMS-based, it's vulnerable to
[[SIM Swapping]], which is why possession-based app/hardware tokens are
considered stronger than SMS.

This is a concrete instance of [[Defense in Depth]] and
[[Security as a Tradeoff]] — it adds real login friction in exchange for
meaningfully raising attacker cost.

Up: [[0 Securing Accounts MOC]]
