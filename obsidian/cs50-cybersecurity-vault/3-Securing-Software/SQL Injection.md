---
tags: [week3, attack]
aliases: [SQL Injection, SQLi]
---

# SQL Injection

A [[Code Injection]] attack where user input is concatenated directly
into a SQL query string, letting an attacker inject their own SQL logic —
classic example: a login form where entering a crafted string as the
username can trick the query into returning a match regardless of the
actual password, or exfiltrate entire database tables the application
never intended to expose.

Root cause: query text and user data are treated as one string instead of
being kept separate. Fix: [[Prepared Statements]], which pass user input
as parameters bound *after* the query structure is already fixed, so
input can never be interpreted as SQL syntax no matter what it contains.

One of the [[OWASP]] Top 10's longest-standing entries, and a frequent
subject of tracked [[Common Vulnerabilities and Exposures CVE]] entries
in real software.

Up: [[3 Securing Software MOC]]
