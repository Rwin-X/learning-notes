---
tags: [week3, concept]
aliases: [CVE]
---

# Common Vulnerabilities and Exposures (CVE)

A standardized, publicly maintained catalog of known software
vulnerabilities, each assigned a unique identifier (e.g. `CVE-2024-XXXXX`)
so the same flaw can be referenced consistently across vendors,
researchers, and tools rather than described inconsistently in prose.

Doesn't rank severity on its own — that's the role of
[[CVSS EPSS and KEV]], which score and prioritize entries. A CVE existing
and being patched only actually protects users once they apply the fix —
see [[Automatic Updates]] — which is why unpatched, publicly known CVEs
remain a common real-world attack vector, distinct from unknown
[[Zero-Day Attacks]].

Fed by [[Bug Bounty]] disclosures, [[Penetration Testing]] findings, and
[[Malware Analysis]] work that identifies what vulnerability a given
piece of malware originally exploited.

Up: [[3 Securing Software MOC]]
