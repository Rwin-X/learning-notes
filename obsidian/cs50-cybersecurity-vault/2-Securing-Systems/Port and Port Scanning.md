---
tags: [week2, concept]
---

# Port and Port Scanning

A **port** is a numbered endpoint on a machine's IP address that a
specific service listens on — e.g. port 443 for [[HTTP vs HTTPS|HTTPS]],
port 22 for [[SSH]]. A single machine can run many services
simultaneously, distinguished by which port each listens on.

**Port scanning**: systematically probing a range of ports on a target to
discover which are open (i.e. which services are running and reachable).
Legitimate use: administrators auditing their own systems, or
[[Penetration Testing]] with authorization. Malicious use: reconnaissance
before an attack, to map what's exposed.

A [[Firewall]] is the primary defense — closing/blocking ports that don't
need to be publicly reachable shrinks what a scan can even find.

Up: [[2 Securing Systems MOC]]
