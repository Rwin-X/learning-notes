---
tags: [concept, cross-cutting]
---

# Threat Model

Before choosing defenses, define: who is the adversary, what do they want,
what capabilities do they have, and what's the cost of a successful attack?

A home user's threat model (opportunistic [[Phishing]], reused passwords,
[[Credential Stuffing]]) is very different from a company's (targeted
[[Social Engineering]], [[Zero-Day Attacks]], insider risk, [[DDoS]]).
The same control can be overkill in one model and insufficient in another —
this is why [[Security as a Tradeoff]] only resolves once the threat model
is explicit.

Recurring adversary capabilities across the course:
- **Passive observation**: [[Packet Sniffing]], reading unencrypted
  [[HTTP]] traffic.
- **Active interception**: [[Machine-in-the-Middle Attacks]].
- **Guessing**: [[Dictionary Attacks]], [[Brute-Force Attacks]].
- **Exploiting trust**: [[Phishing]], [[Cross-Site Request Forgery CSRF]].
- **Exploiting code**: [[SQL Injection]], [[Buffer Overflow]],
  [[Arbitrary Code Execution ACE]].
- **Exploiting metadata/behavior**: [[Fingerprinting]], [[Tracking Cookies]].

See also [[Defense in Depth]].
