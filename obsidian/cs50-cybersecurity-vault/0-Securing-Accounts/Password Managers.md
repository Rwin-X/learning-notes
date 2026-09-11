
---
tags: [week0, concept, defense]
---

# Password Managers

Generate and store a unique, high-entropy password per site, unlocked by
one master password (or passkey/biometric). Directly addresses the root
cause behind [[Credential Stuffing]] (reuse) and makes
[[Dictionary Attacks]]/[[Brute-Force Attacks]] impractical against any
individual account, since generated passwords have no dictionary
structure and sufficient length.

Tradeoff: the master password (or the vault itself) becomes a single
high-value target — its own [[Threat Model]] concern — which is why
managers are typically paired with local [[Full-Disk Encryption]]-style
protection of the vault and often their own 2FA.

Up: [[0 Securing Accounts MOC]]
