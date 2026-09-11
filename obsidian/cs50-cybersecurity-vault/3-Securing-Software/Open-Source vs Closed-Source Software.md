---
tags: [week3, concept]
---

# Open-Source vs. Closed-Source Software

**Open-source**: source code is publicly viewable (and often modifiable).
Security argument for: many eyes can review it, find and report flaws —
connects to [[Bug Bounty]] programs and public
[[Common Vulnerabilities and Exposures CVE]] disclosure being especially
natural here. Security argument against: attackers can study the exact
same code for vulnerabilities just as easily as defenders can.

**Closed-source**: source code is private; attackers generally have to
rely on [[Cracking and Reverse Engineering]] of compiled binaries rather
than reading source directly — "security through obscurity" as a partial,
weak layer, not a substitute for actually secure code.

Neither model is inherently more secure — both depend far more on
whether the code is actually well-written and actively maintained
([[Automatic Updates]], responsible disclosure practices) than on whether
the source is visible.

Up: [[3 Securing Software MOC]]
