---
tags: [week3, concept]
---

# App Stores and Package Managers

Centralized distribution channels for installing software — app stores
for end-user applications (mobile/desktop), package managers for
libraries and system software (pip, npm, apt, etc.). Both act as a trust
and vetting layer between a developer and the systems that install their
code, in principle screening out [[Malware]] before it reaches users.

Security value: a single point where malicious or vulnerable packages
can be caught, removed, or flagged — and where
[[Automatic Updates]] can be centrally coordinated across many users at
once. Security risk: this same centralization is a high-value target —
compromising a popular package or app-store account can distribute
malware to a huge number of downstream users at once (a supply-chain
attack), and vetting is never perfect.

Up: [[3 Securing Software MOC]]
