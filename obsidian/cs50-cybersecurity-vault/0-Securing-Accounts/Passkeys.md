
---
tags: [week0, week1, concept, defense]
---

# Passkeys

A passwordless authentication method built on public-key cryptography
(see [[Public-Key Cryptography]], Week 1): the device holds a private key,
the service holds the matching public key, and login is a cryptographic
challenge-response instead of typing a shared secret.

Why this matters relative to the rest of Week 0:
- Nothing secret is ever transmitted to or typed into a website, so
  classic [[Phishing]] (tricking someone into typing a password into a
  fake page) doesn't work the same way — there's no password to hand over.
- Immune to [[Credential Stuffing]] and [[Dictionary Attacks]] by
  construction — there's no shared secret to leak or reuse.
- Blends [[Multi-Factor Authentication Factors|possession and inherence]]:
  the device is possession, unlocking it (biometric/PIN) is
  inherence/knowledge, combined locally rather than sent over the network.

Up: [[0 Securing Accounts MOC]]
