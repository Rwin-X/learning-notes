
---
domain: Networking Concepts
status: 🔲
tags: [network-plus]
---

# TCP vs UDP

## Key Facts

| | TCP | UDP |
|---|---|---|
| Connection | Connection-oriented | Connectionless |
| Reliability | Guaranteed delivery, ordered | Best-effort, no order guarantee |
| Handshake | 3-way (SYN, SYN-ACK, ACK) | None |
| Overhead | Higher | Lower |
| Use cases | HTTP, FTP, SSH, SMTP | DNS queries, DHCP, VoIP, streaming, SNMP |

## Core Concept

TCP trades speed for reliability via sequencing, acknowledgment, and retransmission. UDP trades reliability for speed — no handshake, no guaranteed order, fire-and-forget.

## Common Exam Traps

- "Which is faster / lower latency" → UDP.
- "Which guarantees delivery" → TCP.
- DNS is UDP for lookups but TCP for zone transfers (>512 bytes) — exam loves this exception.

## Related

- [[OSI Model MOC]]
- [[Ports and Protocols]]
