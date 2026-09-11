---
tags: [week2, concept]
aliases: [SSH, Secure Shell]
---

# SSH (Secure Shell)

An encrypted protocol for remotely accessing and controlling another
machine's command line, replacing older unencrypted protocols (like
Telnet) that sent commands and credentials in plaintext, wide open to
[[Packet Sniffing]].

Typically authenticates using a public/private key pair (see
[[Public-Key Cryptography]]) rather than, or in addition to, a password —
the server holds your public key, and proves you hold the matching
private key during connection, similar in spirit to how [[Passkeys]]
work.

Commonly reached over a specific network [[Port and Port Scanning|port]]
(22 by default), making SSH a common target of
[[Port and Port Scanning|port scanning]] against internet-facing servers.

Up: [[2 Securing Systems MOC]]
