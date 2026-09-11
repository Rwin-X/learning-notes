---
tags: [week1, concept]
---

# Cryptographic Hash Functions

The formal category [[Hashing]] belongs to: one-way functions specifically
designed to be secure against reversal and collision-finding, as opposed
to generic hash functions used elsewhere in computer science (e.g. for
hash tables) where collision-resistance against a deliberate attacker
isn't a design goal.

Required properties:
- **Pre-image resistance** — given a hash, infeasible to find any input
  that produces it.
- **Second pre-image resistance** — given an input, infeasible to find a
  *different* input with the same hash.
- **Collision resistance** — infeasible to find any two inputs that
  collide.

Deliberately slow/expensive variants (e.g. bcrypt, Argon2 — not named in
the official syllabus list but the standard real-world choice) are
preferred for password storage specifically, because slowness directly
raises the cost of [[Brute-Force Attacks]] against a stolen hash database.

Up: [[1 Securing Data MOC]]
