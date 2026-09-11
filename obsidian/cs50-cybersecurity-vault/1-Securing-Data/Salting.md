---
tags: [week1, concept, defense]
---

# Salting

A unique random value (the "salt") added to a password before
[[Hashing]], with the salt stored alongside the resulting hash. Two users
with the identical password now get completely different hashes, because
each has a different salt.

This defeats [[Rainbow Tables]] outright — a precomputed table would need
a separate entry per possible salt value, which is computationally
infeasible at scale — and forces an attacker back to attacking each
password individually via [[Dictionary Attacks]] or
[[Brute-Force Attacks]], one at a time, rather than in bulk.

Salting doesn't make an individual weak password strong — it just removes
the *bulk/precomputation* shortcut. Password strength itself still matters.

Up: [[1 Securing Data MOC]]
