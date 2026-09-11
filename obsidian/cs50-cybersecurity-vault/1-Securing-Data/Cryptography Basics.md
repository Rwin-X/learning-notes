---
tags: [week1, concept]
aliases: [Codes, Ciphers, Encryption, Decryption, Keys]
---

# Cryptography Basics

Foundational vocabulary for the rest of the week:

- **Code** — replaces whole words/phrases with other words/phrases
  (needs a codebook). Different from a **cipher**.
- **Cipher** — transforms text at the level of individual letters/bits
  according to an algorithm plus a **key**.
- **Encryption** — converting plaintext to ciphertext using a key.
- **Decryption** — the reverse, recovering plaintext from ciphertext,
  using a key.
- **Key** — the secret parameter that controls the transformation; the
  algorithm can be public (and usually is, in modern cryptography — see
  Kerckhoffs's principle), but the key must stay secret for
  [[Secret-Key Cryptography]], or the private half must stay secret for
  [[Public-Key Cryptography]].

This is the base vocabulary that [[Secret-Key Cryptography]],
[[Public-Key Cryptography]], and [[Digital Signatures]] all build on.

Up: [[1 Securing Data MOC]]
