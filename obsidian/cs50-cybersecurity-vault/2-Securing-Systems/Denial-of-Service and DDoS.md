---
tags: [week2, concept, attack]
aliases: [DoS, DDoS, Denial-of-Service]
---

# Denial-of-Service (DoS) and Distributed Denial-of-Service (DDoS)

**DoS**: overwhelming a target (server, service, network link) with
traffic or requests until it can no longer serve legitimate users —
availability is the target, not confidentiality or data theft.

**DDoS**: the same idea, but traffic is generated from many distributed
sources at once, typically a [[Malware|botnet]] of compromised machines —
much harder to block than DoS from a single source, since simply blocking
one IP doesn't help against thousands.

Defenses: traffic filtering and rate-limiting (a
[[Firewall]]/[[Deep Packet Inspection]] role), distributed infrastructure
and load balancing to absorb volume, and specialized DDoS-mitigation
services that filter malicious traffic upstream before it reaches the
target.

Up: [[2 Securing Systems MOC]]
