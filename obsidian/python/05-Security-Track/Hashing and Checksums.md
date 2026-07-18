---
title: "Hashing and Checksums"
difficulty: medium
tags:
  - medium
  - security
  - cryptography
---

# Hashing and Checksums

`🟡 MEDIUM` #medium

## What it covers
The `hashlib` module — MD5/SHA family, file integrity checks, HMAC.

## Key points
- MD5/SHA1 are broken for security purposes but still fine for non-adversarial checksums (e.g. dedup)
- Use SHA-256 or better for anything security-relevant
- `hmac.compare_digest()` for constant-time comparison — prevents timing attacks when checking secrets

## Practice
Write a file-integrity checker: hash a directory tree, save a manifest, detect changes on re-run.


## Related
- [[Symmetric Encryption with cryptography lib]]
