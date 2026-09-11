---
tags: [week3, attack]
---

# Command Injection

A [[Code Injection]] attack where user input reaches an operating-system
shell command — often via functions like `system` or `eval` in code —
letting an attacker append or substitute their own commands. Example:
a program that builds a shell command by concatenating a user-supplied
filename can be tricked into running arbitrary additional commands if
the filename contains shell metacharacters.

`eval` is particularly dangerous because it can execute arbitrary code in
the host language itself, not just shell commands — using it on anything
derived from user input is a direct path to
[[Arbitrary Code Execution ACE]].

Fix: avoid passing user input to shell-executing functions at all where
possible; where unavoidable, use APIs that treat arguments as separate
parameters (not a single concatenated string) and strictly validate/allow
list input — the same structural-separation principle as
[[Prepared Statements]] for SQL.

Up: [[3 Securing Software MOC]]
