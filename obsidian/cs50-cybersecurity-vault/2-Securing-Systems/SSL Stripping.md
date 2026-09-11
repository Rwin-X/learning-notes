---
tags: [week2, attack]
---

# SSL Stripping

A [[Machine-in-the-Middle Attacks|machine-in-the-middle]] attack where the
attacker intercepts a user's initial request and silently keeps the
connection on plain [[HTTP vs HTTPS|HTTP]] instead of letting it upgrade
to HTTPS — the user's browser shows what looks like a normal connection,
but never actually establishes [[TLS]], so all traffic is visible to the
attacker via [[Packet Sniffing]].

Works because many sites historically accepted an initial plain-HTTP
request before redirecting to HTTPS, giving an attacker a small window to
intercept that first, unencrypted request. [[HSTS]] exists specifically
to close this window.

Up: [[2 Securing Systems MOC]]
