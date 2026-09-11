---
tags: [week1, concept]
---

# Secure Deletion

Ordinary file deletion usually just removes the filesystem's pointer to
the data — the underlying bits often remain on disk, recoverable with the
right tools, until eventually overwritten by something else. Secure
deletion actively overwrites that data (sometimes multiple times, with
different patterns) so recovery becomes infeasible.

Matters directly for anything that was ever plaintext on disk, even if
briefly: a password typed into a form, a decrypted document opened from
an encrypted archive, a cached copy of a message. It's a separate concern
from [[Full-Disk Encryption]] — encryption protects data while the key
is secret; secure deletion protects data that's supposed to be *gone*,
including on media where encryption was never used to begin with, or
after a key might later be compromised.

On modern SSDs this is more complicated than on old spinning disks —
wear-leveling means a targeted overwrite doesn't always touch the actual
physical cells holding old data, which is part of why full-disk
encryption from the start (so deletion is just "discard the key") is
often the more reliable practical answer than after-the-fact overwriting.

Up: [[1 Securing Data MOC]]
