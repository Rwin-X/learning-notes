---
tags: [week1, concept]
aliases: [Asymmetric-Key Cryptography]
---

# Public-Key Cryptography

Uses a mathematically linked key pair: a **public key** (shared openly)
and a **private key** (kept secret). Data encrypted with the public key
can only be decrypted with the matching private key — solving the key
distribution problem [[Secret-Key Cryptography]] has, since the public
key doesn't need to be kept secret at all.

Also enables the reverse use: signing with the private key, verifiable by
anyone with the public key — see [[Digital Signatures]].

Concrete algorithm: [[RSA]]. Concrete protocol for agreeing on a shared
secret over an insecure channel: [[Diffie-Hellman Key Exchange]].

Real-world applications built directly on this: [[Passkeys]] (Week 0),
[[HTTPS]]/[[TLS]] certificates (Week 2).

Up: [[1 Securing Data MOC]]
