---
tags: [MOC, week3]
---

# Week 3 — Securing Software

Up: [[CS50 Cybersecurity MOC]]

Core question: how do attackers exploit flaws in how software is
written, and how do developers write software that resists those flaws?

## Injection attacks

- [[Code Injection]]
- [[Cross-Site Scripting XSS]]
- [[SQL Injection]]
- [[Prepared Statements]]
- [[Command Injection]]
- [[Character Escapes]]

## Validation and trust boundaries

- [[Client-Side Validation]]
- [[Server-Side Validation]]
- [[Developer Tools]]
- [[Cross-Site Request Forgery CSRF]]
- [[GET and POST]]

## Memory and low-level exploitation

- [[Buffer Overflow and Stack Overflow]]
- [[Arbitrary Code Execution ACE]]

## Vulnerability research and ecosystem

- [[OWASP]]
- [[Cracking and Reverse Engineering]]
- [[Malware Analysis]]
- [[Open-Source vs Closed-Source Software]]
- [[App Stores and Package Managers]]
- [[Bug Bounty]]
- [[Common Vulnerabilities and Exposures CVE]]
- [[CVSS EPSS and KEV]]

## Assignment

Assignment 3 (verify current spec at
cs50.harvard.edu/cybersecurity/assignments/3/).

## Where this connects

- ← [[Phishing]] (Week 0) often delivers or leads into the code-level
  attacks here.
- ← [[Malware]] (Week 2) delivery frequently exploits the exact
  vulnerability classes covered here ([[Buffer Overflow and Stack Overflow]],
  unpatched software tracked via [[Common Vulnerabilities and Exposures CVE]]).
- → Many of the tracking/exploitation techniques here (browser behavior,
  scripts) connect to [[4 Preserving Privacy MOC]].
