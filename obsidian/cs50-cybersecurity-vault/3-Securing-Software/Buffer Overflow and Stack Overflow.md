---
tags: [week3, attack]
aliases: [Buffer Overflow, Stack Overflow]
---

# Buffer Overflow and Stack Overflow

Writing more data into a fixed-size memory buffer than it was allocated
to hold, overwriting adjacent memory — in low-level languages (C and
similar) without automatic bounds checking, this is possible whenever
input length isn't explicitly validated against buffer size.

**Stack overflow** specifically: the overwritten adjacent memory includes
the stack's control data (like a function's return address), letting an
attacker redirect program execution — potentially to attacker-supplied
code, achieving [[Arbitrary Code Execution ACE]].

Distinct from web-layer injection attacks
([[SQL Injection]], [[Cross-Site Scripting XSS]]) in that this operates
at the memory/binary level rather than through a query or script
interpreter — but the underlying pattern is the same: untrusted input
reaching somewhere it can be misinterpreted as more than plain data,
without validation. Central to [[Cracking and Reverse Engineering]] and
[[Malware Analysis]] work.

Up: [[3 Securing Software MOC]]
