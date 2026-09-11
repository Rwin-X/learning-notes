
---
tags: [week0, concept]
aliases: [MFA]
---

# Multi-Factor Authentication: Factors

Three categories of proof used in [[Authentication]]; combining more than
one from *different* categories is what makes
[[Two-Factor Authentication 2FA]] meaningfully stronger than two secrets
of the same kind.

- **Knowledge** — something you know: a password, a PIN.
- **Possession** — something you have: a phone (for an
  [[One-Time Password OTP]]), a hardware key.
- **Inherence** — something you are: fingerprint, face ID (biometrics).

Two passwords is not MFA — it's still one factor (knowledge), repeated.
[[Passkeys]] blend possession (the device holding the key) with
inherence/knowledge used to unlock that device locally.

Up: [[0 Securing Accounts MOC]]
