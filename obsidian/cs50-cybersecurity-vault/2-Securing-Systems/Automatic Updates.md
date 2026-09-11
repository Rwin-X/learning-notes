---
tags: [week2, concept, defense]
---

# Automatic Updates

Patches for known vulnerabilities applied automatically, without waiting
for a user to manually install them. Directly closes the window between
"a vulnerability is publicly known/patched" and "this specific machine is
still exploitable" — the gap attackers rely on when a fix exists but
hasn't been applied yet.

Connects to [[Common Vulnerabilities and Exposures CVE]] (Week 3): a CVE
being published and patched doesn't protect anyone who hasn't updated.
Distinct from [[Zero-Day Attacks]], where no patch exists yet at all —
automatic updates help once a fix ships, but can't help before one exists.

Tradeoff: automatic updates occasionally introduce bugs or break
compatibility, which is a real cost weighed against the security benefit
— see [[Security as a Tradeoff]].

Up: [[2 Securing Systems MOC]]
