---
tags: [week1, week2, attack]
---

# Ransomware

Malware (see [[Malware]], Week 2) that encrypts a victim's files using
the attacker's key, then demands payment for the decryption key needed to
recover them. A direct, hostile misuse of the same
[[Encryption in Transit vs at Rest|encryption-at-rest]] concept that
normally protects data — here the attacker encrypts *against* the owner
instead of for them.

Why backups matter as the primary defense: since the encryption itself is
typically cryptographically sound (breaking it directly is usually
infeasible), the practical countermeasure isn't cryptanalysis — it's
having offline/versioned backups so paying the ransom isn't the only path
to recovery. This is a case where [[Defense in Depth]] shows up as
*recovery* planning, not just prevention.

Delivery typically follows the same paths as other malware: [[Phishing]],
malicious downloads, unpatched software (see [[Zero-Day Attacks]] and
[[Automatic Updates]]).

Up: [[1 Securing Data MOC]] · [[2 Securing Systems MOC]]
