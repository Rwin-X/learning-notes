---
tags: [MOC, week4]
---

# Week 4 — Preserving Privacy

Up: [[CS50 Cybersecurity MOC]]

Core question: what information do you share — often without realizing
it — just by browsing, and how much of that can actually be restricted?

## What gets recorded

- [[Web Browsing History]]
- [[Logs]]
- [[HTTP Headers]]
- [[Fingerprinting]]

## Cookies, in the privacy sense

- [[Session Cookies vs Tracking Cookies]]
- [[Tracking Parameters]]
- [[Third-Party Cookies]]
- [[Private Browsing]]
- [[Supercookies]]

## DNS and its privacy implications

- [[DNS Privacy]]
- [[DNS over HTTPS and DNS over TLS]]

## Taking back control

- [[VPN]] (see also [[2 Securing Systems MOC]])
- [[Tor]]
- [[Permissions]]

## Assignment

Assignment 4 (verify current spec at
cs50.harvard.edu/cybersecurity/assignments/4/).

## Where this connects

- ← [[Session Hijacking and Cookies]] (Week 2) introduced cookies for
  authentication; here the same mechanism is examined for tracking.
- ← [[VPN]] (Week 2) reappears here specifically through a privacy lens
  rather than a network-security lens — same tool, different threat model
  (advertisers/observers vs. network attackers).
- ← [[End-to-End Encryption]] (Week 1) protects message *content*; this
  week is largely about *metadata* — who you talked to, when, from where
  — which E2EE alone doesn't hide.
- This week ties the whole course together: privacy is the accumulated
  effect of every earlier week's choices (weak auth exposes account data;
  unencrypted traffic exposes browsing; insecure software leaks data) —
  see [[Security as a Tradeoff]].
