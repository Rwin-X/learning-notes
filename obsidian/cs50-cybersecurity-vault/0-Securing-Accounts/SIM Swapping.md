---
tags: [week0, attack]
---

# SIM Swapping

An attacker convinces (or bribes/social-engineers) a mobile carrier to
port a victim's phone number to a SIM the attacker controls. Once
successful, the attacker receives the victim's SMS-based
[[One-Time Password OTP]] codes, defeating SMS-based
[[Two-Factor Authentication 2FA]] entirely.

This is a form of [[Social Engineering]] aimed at the carrier's support
process, not the victim directly — a reminder that a
[[Threat Model]] has to account for weak links outside the target's own
systems.

Mitigation: prefer app-based or hardware-based possession factors over
SMS where the threat model warrants it.

Up: [[0 Securing Accounts MOC]]
