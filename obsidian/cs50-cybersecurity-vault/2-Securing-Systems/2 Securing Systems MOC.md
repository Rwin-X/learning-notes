---
tags: [MOC, week2]
---

# Week 2 — Securing Systems

Up: [[CS50 Cybersecurity MOC]]

Core question: how is data protected as it moves across networks, and how
are the machines and networks themselves protected from intrusion?

## Wireless and web transport

- [[Wi-Fi Protected Access]]
- [[HTTP vs HTTPS]]
- [[TLS]]
- [[Certificate and Certificate Authority]]
- [[SSL Stripping]]
- [[HSTS]]

## Interception attacks

- [[Packet Sniffing]]
- [[Session Hijacking and Cookies]]

## Network access and defense

- [[VPN]]
- [[SSH]]
- [[Port and Port Scanning]]
- [[Penetration Testing]]
- [[Firewall]]
- [[Deep Packet Inspection]]
- [[Proxy]]

## Malicious software and attacks

- [[Malware]] — virus, worm, botnet
- [[Denial-of-Service and DDoS]]
- [[Antivirus]]
- [[Automatic Updates]]
- [[Zero-Day Attacks]]

## Assignment

Assignment 2 (verify current spec at
cs50.harvard.edu/cybersecurity/assignments/2/).

## Where this connects

- ← [[Machine-in-the-Middle Attacks]] (Week 0) gets its full mechanics
  here via [[Packet Sniffing]] and [[Session Hijacking]].
- ← [[Public-Key Cryptography]] and [[Digital Signatures]] (Week 1) are
  exactly what [[TLS]] and [[Certificate and Certificate Authority]]
  apply to web traffic.
- → [[Malware]] delivery often exploits the software vulnerabilities
  covered in [[3 Securing Software MOC]].
