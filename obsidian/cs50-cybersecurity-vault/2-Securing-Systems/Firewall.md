---
tags: [week2, concept, defense]
---

# Firewall

A control point that filters network traffic in or out of a machine or
network, based on rules — allowing traffic on ports/services that should
be reachable, blocking everything else. Directly shrinks what
[[Port and Port Scanning]] can discover and what an attacker can even
attempt to reach in the first place.

Can operate at different levels: simple rule-based filtering (allow/deny
by IP, port, protocol) up through [[Deep Packet Inspection]], which
actually examines packet contents rather than just headers.

One piece of [[Defense in Depth]] — a firewall reduces attack surface,
but doesn't substitute for patched software ([[Automatic Updates]]),
[[Antivirus]], or the software-level defenses in
[[3 Securing Software MOC]] for whatever *is* allowed through.

Up: [[2 Securing Systems MOC]]
