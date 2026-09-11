---
tags: [week3, concept]
aliases: [CVSS, EPSS, KEV]
---

# CVSS, EPSS, and KEV

Three complementary systems for prioritizing which
[[Common Vulnerabilities and Exposures CVE|CVEs]] actually matter most to
fix first — because thousands of CVEs exist and not all carry equal
urgency:

- **CVSS (Common Vulnerability Scoring System)**: a numeric score (0–10)
  rating a vulnerability's *theoretical severity* — how bad it would be
  if exploited, factoring in things like whether it enables
  [[Arbitrary Code Execution ACE]], whether it's remotely reachable, and
  how much privilege it requires.
- **EPSS (Exploit Prediction Scoring System)**: estimates the
  *probability* a vulnerability will actually be exploited in the wild in
  the near future — severity and likelihood aren't the same thing, so a
  moderately severe but heavily targeted flaw can matter more practically
  than a severe but rarely-exploited one.
- **KEV (Known Exploited Vulnerabilities Catalog)**: a list of
  vulnerabilities *confirmed* to have already been actively exploited —
  the highest-priority signal of the three, since it's observed reality
  rather than a score or a prediction.

Together they answer three different questions: how bad could this be
(CVSS), how likely is it to be attacked (EPSS), and is it already being
attacked (KEV) — directly informing what
[[Automatic Updates]]/patching should prioritize first.

Up: [[3 Securing Software MOC]]
