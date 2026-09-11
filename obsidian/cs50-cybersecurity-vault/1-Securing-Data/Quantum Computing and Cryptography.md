---
tags: [week1, concept]
---

# Quantum Computing and Cryptography

A future/emerging threat to current public-key cryptography. Algorithms
like Shor's algorithm, run on a sufficiently large and stable quantum
computer, could factor large numbers and solve discrete-log problems
efficiently — breaking the mathematical hardness assumptions
[[RSA]] and [[Diffie-Hellman Key Exchange]] rely on.

Doesn't threaten [[Hashing]] or [[Secret-Key Cryptography]] nearly as
severely — quantum attacks against those (e.g. Grover's algorithm) only
roughly halve effective key strength, which is manageable by doubling key
length, unlike the more fundamental break quantum computing poses to
current public-key schemes.

Practical implication already underway in industry: "post-quantum
cryptography," designing new algorithms whose hardness assumptions don't
rely on factoring or discrete log, so systems can migrate before
large-scale quantum computers become practical.

Up: [[1 Securing Data MOC]]
