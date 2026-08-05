---
type: concept
domain: cryptography
status: growing
created: 2026-07-17
tags: [concept, crypto, symmetric-encryption]
---

# AES-256-GCM

## Definition
> AES-256-GCM is a symmetric encryption scheme combining the AES block cipher (256-bit key) in Galois/Counter Mode, which provides both confidentiality (encryption) and integrity/authenticity (via an authentication tag) in a single pass.

## Why It Matters
- It's an AEAD (Authenticated Encryption with Associated Data) cipher — you get tamper detection for free, unlike plain AES-CBC.
- Industry standard for file/data encryption where both secrecy and integrity matter.
- Used across nearly all of your own crypto tooling: [[secNT]], [[STG_CRY]], [[CipherVault]].

## How It Works
- AES in Counter (CTR) mode encrypts the plaintext block-by-block using a keystream derived from a nonce + counter.
- GHASH (Galois hash) computes an authentication tag over the ciphertext (and optional associated data) to detect tampering.
- Output = ciphertext + 128-bit auth tag. Decryption fails loudly if the tag doesn't match.

## Related Concepts
- [[Symmetric vs Asymmetric Encryption]]
- [[Argon2id Key Derivation]] — GCM needs a strong key; Argon2id is how you derive one from a password
- [[Nonce Reuse in GCM]] — the single most dangerous mistake with this cipher

## Attack / Defense Angle
- **Offensive relevance:** if a nonce is ever reused with the same key, GCM's authentication and confidentiality both break catastrophically — this is the #1 real-world GCM vulnerability to know for CEH/Security+.
- **Defensive relevance:** always use a cryptographically random 96-bit (12-byte) nonce per encryption operation, never reuse a (key, nonce) pair, and never hand-roll your own nonce counter logic.

## Source
- Python `cryptography` library docs
- Used practically in: [[secNT]], [[CipherVault]]

## Questions / Open Threads
- [ ] Compare GCM vs ChaCha20-Poly1305 performance on constrained hardware
- [ ] Document exact nonce-generation strategy used in secNT for future audit
