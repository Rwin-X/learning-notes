---
tags: [week3, concept]
aliases: [ACE, RCE, Remote Code Execution]
---

# Arbitrary Code Execution (ACE) / Remote Code Execution (RCE)

The most severe class of outcome a vulnerability can lead to: the
attacker can make the target system run code of the attacker's choosing.
**RCE** specifically means this is achievable remotely, over a network,
without physical or prior authenticated access — the highest-severity,
highest-priority category in practice.

The end goal many other vulnerabilities in this week ultimately reach
toward: a [[Buffer Overflow and Stack Overflow|stack overflow]] that
redirects execution, or a [[Command Injection]] that runs attacker
commands, are both specific *paths* to ACE/RCE. This severity is exactly
what [[CVSS EPSS and KEV|CVSS scoring]] weighs heavily when rating a
[[Common Vulnerabilities and Exposures CVE]] entry.

Up: [[3 Securing Software MOC]]
