---
domain: Security
status: 🔲
tags: [network-plus, security]
---

# Security Concepts

## CIA Triad

- **Confidentiality**: only authorized parties can access data (encryption).
- **Integrity**: data hasn't been altered (hashing).
- **Availability**: systems are accessible when needed (redundancy, DR).

## Core Models

- **Zero Trust**: never trust, always verify — no implicit trust by network location; continuous verification per session/request.
- **Defense in depth**: layered security controls, no single point of failure.
- **Least privilege**: users/systems get only the access needed to do their job.
- **AAA**: Authentication (who you are), Authorization (what you can do), Accounting (logging what you did).

## Network Access Control

- **802.1X**: port-based network access control, requires authentication before granting network access (uses EAP).
- **NAC (Network Access Control)**: broader posture-checking before granting access (patch level, AV status, etc.).
- **RADIUS**: AAA protocol, UDP, encrypts only the password.
- **TACACS+**: Cisco AAA protocol, TCP, encrypts entire payload, separates AAA functions.

## Common Exam Traps

- RADIUS vs TACACS+ is a guaranteed test item: RADIUS = UDP, password-only encryption; TACACS+ = TCP, full encryption, separates A-A-A.
- Zero Trust ≠ "no trust ever" — it means no *implicit* trust based on location; verification is continuous.

## Related

- [[Network Attacks]]
- [[Network Hardening]]
