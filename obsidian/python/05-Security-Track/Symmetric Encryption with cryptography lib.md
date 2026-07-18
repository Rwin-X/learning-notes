---
title: "Symmetric Encryption with cryptography lib"
difficulty: hard
tags:
  - hard
  - security
  - cryptography
---

# Symmetric Encryption with cryptography lib

`🟠 HARD` #hard

## What it covers
Real, modern encryption in Python using the `cryptography` library — AES-256-GCM, key derivation (Argon2id/PBKDF2), the same stack behind your `secNT` and `CipherVault` projects.

## Key points
- Never write your own crypto primitives — use vetted libraries (`cryptography`, not homemade XOR)
- AES-GCM gives you both confidentiality **and** integrity (authenticated encryption) — prefer it over plain CBC
- Argon2id for password-based key derivation resists GPU cracking better than PBKDF2

## Practice
This is essentially a review note for you — trace through your own `secNT` or `CipherVault` source and annotate each crypto call with *why* that primitive was chosen.


## Related
- [[Hashing and Checksums]]
- [[Building a Password Manager CLI]]
