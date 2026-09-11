
---
tags: [concept, cross-cutting]
---

# Security as a Tradeoff

Security is not binary (secure / insecure). It's relative:

- For an **adversary**: risk (of getting caught, of failure) vs. **reward**
  (data, money, access).
- For **you**: cost (money, time, friction) vs. **benefit** (what's
  protected, and how much).
- Against **usability**: every control added (a longer password, 2FA, a
  VPN) makes the system harder to use. Security that's too inconvenient
  gets bypassed by real users — see [[Social Engineering]], where the
  weakest link is often a person routing around a control.

This framing recurs in every week:
- Week 0: [[Two-Factor Authentication 2FA]] adds friction to gain protection
  against [[Credential Stuffing]] and [[Phishing]].
- Week 1: [[Full-Disk Encryption]] costs performance/complexity for
  protection against physical theft.
- Week 2: a [[Firewall]] costs some connectivity for reduced attack surface.
- Week 3: input validation costs developer time for protection against
  [[SQL Injection]] and [[Cross-Site Scripting XSS]].
- Week 4: [[VPN]]/[[Tor]] cost speed and convenience for privacy.

See also [[Threat Model]] — the tradeoff only makes sense once you know
who you're actually defending against.
