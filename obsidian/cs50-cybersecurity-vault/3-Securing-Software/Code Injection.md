---
tags: [week3, concept, attack]
---

# Code Injection

The umbrella category: an attacker supplies input that gets interpreted
as *code or commands* rather than as inert *data*, because the program
didn't clearly separate the two. Every specific injection attack this
week is a variant of this same root cause.

- [[Cross-Site Scripting XSS]] — injected input runs as script in a
  victim's browser.
- [[SQL Injection]] — injected input runs as part of a database query.
- [[Command Injection]] — injected input runs as an operating-system
  command.

Root fix across all of them is the same principle: never build
code/queries/commands by directly concatenating untrusted input into a
string that gets executed or interpreted. Concrete mechanisms:
[[Character Escapes]], [[Prepared Statements]], and rigorous
[[Server-Side Validation]].

Up: [[3 Securing Software MOC]]
