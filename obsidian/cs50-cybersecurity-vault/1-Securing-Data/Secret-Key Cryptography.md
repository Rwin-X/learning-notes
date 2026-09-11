---
tags: [week1, concept]
aliases: [Symmetric-Key Cryptography]
---

# Secret-Key Cryptography

The same key both encrypts and decrypts (symmetric). Fast and efficient
for actually encrypting bulk data, but has a hard distribution problem:
both parties need the same secret key beforehand, and getting it to them
securely, over a channel an adversary might be watching, is exactly the
problem [[Public-Key Cryptography]] solves.

In practice, real systems use both together: [[Diffie-Hellman Key Exchange]]
or [[RSA]] (public-key methods) to securely agree on or transmit a
one-time secret key, then secret-key cryptography to actually encrypt the
data efficiently. This hybrid approach underlies [[End-to-End Encryption]]
and [[HTTPS]]/[[TLS]] (Week 2).

Up: [[1 Securing Data MOC]]
