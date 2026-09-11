---
tags: [week2, concept]
aliases: [DPI]
---

# Deep Packet Inspection (DPI)

A more thorough form of traffic filtering than a basic
[[Firewall]]: instead of only checking packet headers (source/destination
IP, port), DPI examines the actual payload/content of packets, looking
for specific patterns — malware signatures, protocol violations, banned
content.

Tradeoff worth noting (see [[Security as a Tradeoff]]): DPI can't inspect
content it can't read — encrypted traffic ([[TLS]]) limits what DPI can
see without additional measures like TLS interception, which itself
raises its own trust and privacy concerns, connecting to
[[4 Preserving Privacy MOC]].

Up: [[2 Securing Systems MOC]]
