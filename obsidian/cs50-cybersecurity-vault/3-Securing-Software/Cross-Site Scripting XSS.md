---
tags: [week3, attack]
aliases: [XSS, Cross-Site Scripting]
---

# Cross-Site Scripting (XSS)

A [[Code Injection]] attack where an attacker gets malicious script to
run in *another user's* browser, in the context of a trusted site — the
script can then read page content, steal session
[[Session Hijacking and Cookies|cookies]], or act as the victim.

Two main forms:
- **Reflected**: the malicious script comes from the current request
  (e.g. a crafted link) and is immediately reflected back into the page
  without being stored — the victim has to click a specific malicious
  link.
- **Stored**: the malicious script is saved server-side (e.g. in a
  comment field) and served to *every* user who later views that content
  — no individual malicious link needed, far more dangerous in reach.

Root cause: user-supplied input gets rendered as HTML/JavaScript instead
of as inert text. Fixed by [[Character Escapes]] (converting `<script>`
into harmless displayable text) applied consistently wherever untrusted
input is output, not just where it's input.

Up: [[3 Securing Software MOC]]
