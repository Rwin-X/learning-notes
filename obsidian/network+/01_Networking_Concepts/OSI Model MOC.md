
---
domain: Networking Concepts
status: 🔲
tags: [network-plus, osi]
---

# OSI Model

## Core Concept

7 layers, top-down or bottom-up. Mnemonic: **A**ll **P**eople **S**eem **T**o **N**eed **D**ata **P**rocessing (7→1).

## Layers

| # | Layer | PDU | Examples |
|---|---|---|---|
| 7 | Application | Data | HTTP, FTP, DNS, SMTP |
| 6 | Presentation | Data | TLS/SSL, encryption, encoding |
| 5 | Session | Data | Session establishment, NetBIOS |
| 4 | Transport | Segment (TCP) / Datagram (UDP) | TCP, UDP, port numbers |
| 3 | Network | Packet | IP, ICMP, routers |
| 2 | Data Link | Frame | MAC address, switches, ARP |
| 1 | Physical | Bits | Cables, hubs, NICs |

## Key Facts

- Switches operate at Layer 2 (some multilayer switches at L3).
- Routers operate at Layer 3.
- Firewalls can operate at multiple layers (L3/L4 traditional, L7 for NGFW/application-aware).
- Encapsulation happens top-down when sending; de-encapsulation bottom-up when receiving.

## Common Exam Traps

- Don't confuse "segment" (TCP) vs "datagram" (UDP) at Layer 4 — PBQs test this.
- A device "operating at Layer X" question usually wants the *primary* function layer, not every layer it touches.

## Related

- [[TCP vs UDP]]
- [[Ports and Protocols]]
