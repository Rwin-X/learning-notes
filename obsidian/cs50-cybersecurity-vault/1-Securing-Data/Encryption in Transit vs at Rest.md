---
tags: [week1, concept]
---

# Encryption in Transit vs. at Rest

Two different moments data needs protecting, requiring different
mechanisms:

- **In transit**: while data moves across a network, vulnerable to
  [[Machine-in-the-Middle Attacks]] and [[Packet Sniffing]]. Protected by
  [[HTTPS]]/[[TLS]] (Week 2) and, for messaging specifically,
  [[End-to-End Encryption]].
- **At rest**: while data sits on a disk (a laptop, a phone, a server),
  vulnerable to physical theft or unauthorized filesystem access.
  Protected by [[Full-Disk Encryption]].

A system can have one without the other — e.g. a message encrypted in
transit via HTTPS but stored unencrypted on the server's disk once
delivered. Full protection requires addressing both.

Up: [[1 Securing Data MOC]]
