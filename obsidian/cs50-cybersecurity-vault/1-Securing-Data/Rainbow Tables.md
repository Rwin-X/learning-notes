---
tags: [week1, attack]
---

# Rainbow Tables

A precomputed lookup table mapping common passwords (and variants) to
their [[Hashing|hashed]] values, letting an attacker reverse a stolen hash
back to its plaintext password almost instantly — no brute-forcing at
guess time, since the work was done once, in advance.

Only effective against unsalted hashes. [[Salting]] defeats this class of
attack entirely, because the attacker would need a separate precomputed
table per salt value, which isn't feasible.

Up: [[1 Securing Data MOC]]
