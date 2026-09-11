
---
tags: [week0, concept, defense]
aliases: [SSO]
---

# Single Sign-On (SSO)

Authenticate once with a single trusted identity provider (Google,
Microsoft, a school/company account), then use that session to access
many other services without a separate password each.

Tradeoff (see [[Security as a Tradeoff]]): fewer passwords to manage and
phish individually, but the identity provider becomes a single point of
failure — compromise that one account and every connected service is
reachable. In practice usually paired with strong
[[Two-Factor Authentication 2FA]] on the identity-provider account
specifically, since it now guards everything downstream.

Reduces the attack surface [[Phishing]] and [[Credential Stuffing]] can
exploit, since there's one credential instead of many reused ones.

Up: [[0 Securing Accounts MOC]]
