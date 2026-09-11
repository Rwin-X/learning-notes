---
tags: [week2, concept]
---

# TLS (Transport Layer Security)

The protocol that actually implements the encryption behind [[HTTPS]]
(and other encrypted protocols). Handshake sequence, roughly:

1. Client and server negotiate which cryptographic algorithms to use.
2. Server presents its [[Certificate and Certificate Authority|certificate]]
   to prove identity.
3. A shared session key is established — historically via
   [[RSA]]-based exchange, in modern TLS typically via
   [[Diffie-Hellman Key Exchange]] (specifically ephemeral variants, for
   forward secrecy).
4. Actual data is encrypted using [[Secret-Key Cryptography]] with that
   session key, for speed.

Defeats [[Machine-in-the-Middle Attacks]] and [[Packet Sniffing]] on the
data itself, provided certificate validation isn't bypassed or tricked —
that's the part [[SSL Stripping]] specifically tries to avoid entirely by
never letting TLS start in the first place.

Up: [[2 Securing Systems MOC]]
