---
tags: [week2, concept, defense]
---

# Antivirus

Software that detects and removes [[Malware]], primarily via two
approaches:

- **Signature-based**: matching files/behavior against a database of
  known malware patterns. Fast and reliable for known threats, blind to
  brand-new ones.
- **Heuristic/behavior-based**: flagging suspicious *behavior* (e.g. a
  program trying to encrypt many files rapidly, resembling
  [[Ransomware]]) even without a matching signature — catches novel
  threats at the cost of more false positives.

Limitation directly relevant to [[Zero-Day Attacks]]: signature-based
detection can't catch malware it has never seen before, which is exactly
what makes zero-days dangerous — no signature exists yet. This is why
antivirus is one layer of [[Defense in Depth]], not a complete solution
on its own.

Up: [[2 Securing Systems MOC]]
