---
tags: [week2, concept, attack]
aliases: [Session Hijacking, Cookies]
---

# Cookies and Session Hijacking

**Cookies**: small pieces of data a site stores in the browser, commonly
used to maintain a logged-in session — after [[Authentication]], the
server issues a session cookie so the user doesn't have to re-enter a
password on every request.

**Session hijacking**: an attacker captures that session cookie (via
[[Packet Sniffing]] on an unencrypted connection, or via
[[Cross-Site Scripting XSS]] in Week 3) and reuses it to impersonate the
logged-in user — without ever needing the actual password. The account is
compromised even though [[Usernames and Passwords|credentials]] were
never directly stolen.

Mitigations: transmitting cookies only over [[HTTPS]] (the `Secure` flag),
making them inaccessible to page scripts (the `HttpOnly` flag, which
directly blocks the XSS-based theft vector), and short session lifetimes.

Up: [[2 Securing Systems MOC]]
