---
tags: [week1, concept]
---

# Hashing

A one-way function that maps input of any size to a fixed-size output
(a "hash" or "digest"). One-way means: easy to compute forward, infeasible
to reverse. Used to store [[Usernames and Passwords|passwords]] without
storing the plaintext — the server stores the hash, and on login re-hashes
the entered password and compares.

Properties that matter for security (see
[[Cryptographic Hash Functions]] for the formal definitions):
- Deterministic: same input always produces the same hash.
- Small input change → wildly different output (avalanche effect).
- Collision-resistant: infeasible to find two inputs with the same hash.

Weakness on its own: identical passwords produce identical hashes, so an
attacker with a precomputed table of common-password hashes
([[Rainbow Tables]]) can reverse-lookup without brute-forcing. This is
exactly what [[Salting]] fixes.

Up: [[1 Securing Data MOC]]
