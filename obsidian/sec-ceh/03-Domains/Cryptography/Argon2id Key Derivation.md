---
type: concept
domain: cryptography
status: growing
created: 2026-07-17
tags: [concept, crypto, key-derivation]
---

# Argon2id Key Derivation

## Definition
> Argon2id is a memory-hard password hashing / key derivation function and winner of the 2015 Password Hashing Competition. It hybridizes Argon2i (side-channel resistant) and Argon2d (GPU-cracking resistant) to defend against both attack classes.

## Why It Matters
- Turns a human-memorable password into a cryptographically strong key suitable for AES-256-GCM.
- "Memory-hard" means attackers can't easily parallelize cracking attempts on GPUs/ASICs the way they can with fast hashes like SHA-256.
- This is the KDF backing [[secNT]] and your incomplete PyQt6 password manager.

## How It Works
- Three tunable cost parameters: **time cost** (iterations), **memory cost** (KB of RAM required), **parallelism** (threads).
- A random **salt** is required per-derivation to defeat rainbow tables.
- Output is a fixed-length key (e.g., 32 bytes for AES-256) deterministically derived from password + salt + params.

## Related Concepts
- [[AES-256-GCM]] — the cipher this key typically feeds into
- [[Hashing vs Encryption vs Encoding]]
- [[Weak Key Derivation]] — what happens when you skip this and use raw SHA-256 on a password

## Attack / Defense Angle
- **Offensive relevance:** low memory-cost parameters make Argon2id crackable at scale; check configs during pentests/CTFs.
- **Defensive relevance:** OWASP-recommended baseline is roughly 19 MiB memory / 2 iterations / 1 degree of parallelism minimum for interactive logins — tune upward for standalone tools like a desktop encryption app where UX latency matters less.

## Source
- Python `argon2-cffi` library
- Used practically in: [[secNT]]

## Questions / Open Threads
- [ ] Document the exact params used in secNT and PassVault-style rebuild for consistency
- [ ] Benchmark derivation time on target hardware to tune parallelism param
