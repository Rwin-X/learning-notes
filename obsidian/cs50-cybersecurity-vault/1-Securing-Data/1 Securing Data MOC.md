---
tags: [MOC, week1]
---

# Week 1 — Securing Data

Up: [[CS50 Cybersecurity MOC]]

Core question: how is data protected at rest and in transit — passwords
turned into unreadable form, messages encrypted so only the intended
recipient can read them?

## Storing passwords

- [[Hashing]]
- [[Salting]]
- [[Rainbow Tables]]
- [[Cryptographic Hash Functions]]

## Cryptography fundamentals

- [[Cryptography Basics]] — codes, ciphers, keys
- [[Secret-Key Cryptography]]
- [[Public-Key Cryptography]]
- [[RSA]]
- [[Diffie-Hellman Key Exchange]]
- [[Digital Signatures]]
- [[Cryptanalysis]]

## Applying it

- [[Encryption in Transit vs at Rest]]
- [[End-to-End Encryption]]
- [[Full-Disk Encryption]]
- [[Secure Deletion]]
- [[Ransomware]]
- [[Quantum Computing and Cryptography]]

## Assignment

Assignment 1 (verify current spec at
cs50.harvard.edu/cybersecurity/assignments/1/).

## Where this connects

- ← [[Dictionary Attacks]] and [[Brute-Force Attacks]] from Week 0 are
  exactly what [[Hashing]] + [[Salting]] defend stored passwords against.
- → [[HTTPS]] and [[TLS]] in Week 2 are [[Public-Key Cryptography]]
  applied to web traffic.
- → [[Passkeys]] (Week 0) rely on the public/private key model introduced
  here.
