---
tags: [week3, concept, defense]
---

# Server-Side Validation

Re-checking every piece of input on the server, regardless of whatever
[[Client-Side Validation]] already happened in the browser — because the
client can never be trusted. This is the actual security boundary; the
server is the only place validation can't be bypassed by the requester.

Same principle as [[Authorization]] needing to be checked server-side per
action, not assumed from a client-reported state. Missing server-side
validation is the root cause behind [[SQL Injection]],
[[Cross-Site Scripting XSS]], and [[Command Injection]] all being
exploitable — each is, at bottom, a case of untrusted input reaching
somewhere sensitive without being properly checked or neutralized first.

Up: [[3 Securing Software MOC]]
