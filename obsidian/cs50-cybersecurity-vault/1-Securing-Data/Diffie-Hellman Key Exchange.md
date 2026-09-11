---
tags: [week1, concept]
---

# Diffie-Hellman Key Exchange

A protocol letting two parties agree on a shared secret key over a
public, insecure channel — without ever transmitting the key itself, and
without needing to have met beforehand. An eavesdropper who sees the
entire exchange still can't (practically) compute the resulting shared
secret.

Solves the same core problem [[Public-Key Cryptography]] solves (secure
key agreement without a pre-shared secret), via different math than
[[RSA]]. Commonly used to bootstrap a session key that then gets used
with fast [[Secret-Key Cryptography]] for the actual data — this is
essentially how key setup works inside [[TLS]] (Week 2).

Up: [[1 Securing Data MOC]]
