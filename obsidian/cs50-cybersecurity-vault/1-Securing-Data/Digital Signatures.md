---
tags: [week1, concept]
---

# Digital Signatures

Uses [[Public-Key Cryptography]] in reverse: sign with the private key,
verify with the public key. Proves two things at once — the message
really came from the holder of that private key (authenticity), and it
wasn't altered after signing (integrity).

Typically implemented as: hash the message (see [[Hashing]]), then encrypt
that hash with the private key. Anyone can decrypt the signature with the
public key and compare it against their own hash of the message.

Underpins [[Certificate]]/[[X.509]] trust in [[HTTPS]] (Week 2) — a
Certificate Authority digitally signs a site's certificate, and browsers
verify that signature to trust the site's public key.

Up: [[1 Securing Data MOC]]
