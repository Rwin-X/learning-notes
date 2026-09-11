---
tags: [week1, concept]
---

# RSA

A concrete [[Public-Key Cryptography]] algorithm (Rivest–Shamir–Adleman).
Security rests on the practical difficulty of factoring the product of
two large prime numbers: multiplying two large primes together is fast;
recovering the original primes from the product is not, with classical
computers, at key sizes used in practice.

This asymmetry (easy one direction, hard the other) is exactly the kind
of one-way structure cryptography depends on — same spirit as
[[Hashing]] being easy to compute and hard to reverse, though the
mathematical basis is different.

Relevant threat: [[Quantum Computing and Cryptography]] — a sufficiently
capable quantum computer could factor large numbers efficiently, breaking
RSA's underlying assumption.

Up: [[1 Securing Data MOC]]
