---
tags: [week1, concept, defense]
---

# Full-Disk Encryption

Encrypts an entire storage drive so its contents are unreadable without
the decryption key/passphrase — the "at rest" half of
[[Encryption in Transit vs at Rest]]. Protects against physical theft: a
stolen laptop or drive yields ciphertext, not files, without the key.

Tradeoff (see [[Security as a Tradeoff]]): some performance overhead, and
total reliance on the passphrase/key — lose it, lose the data. This is
why full-disk encryption is usually paired with [[Password Managers]] or
recovery-key backup schemes rather than a single memorized passphrase
with no fallback.

Doesn't protect data once the disk is unlocked and the system is running
— that's a different threat model (malware with live access, for
instance) than the "drive at rest, powered off or locked" case it's
designed for.

Up: [[1 Securing Data MOC]]
