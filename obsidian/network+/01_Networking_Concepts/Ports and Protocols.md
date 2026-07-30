
---
domain: Networking Concepts
status: 🔲
tags: [network-plus, ports]
---

# Ports and Protocols

See also: [[Port Numbers Cheatsheet]] for the full quick-reference table.

## Key Facts

- **Well-known ports**: 0–1023
- **Registered ports**: 1024–49151
- **Dynamic/ephemeral ports**: 49152–65535
- TCP = connection-oriented, reliable, 3-way handshake (SYN, SYN-ACK, ACK).
- UDP = connectionless, no guarantee of delivery, lower overhead (used for DNS queries, DHCP, streaming, VoIP).

## Must-Know Ports (high-yield)

| Port | Protocol | Transport |
|---|---|---|
| 20/21 | FTP | TCP |
| 22 | SSH | TCP |
| 23 | Telnet | TCP |
| 25 | SMTP | TCP |
| 53 | DNS | TCP/UDP |
| 67/68 | DHCP | UDP |
| 80 | HTTP | TCP |
| 110 | POP3 | TCP |
| 123 | NTP | UDP |
| 143 | IMAP | TCP |
| 161/162 | SNMP | UDP |
| 389 | LDAP | TCP |
| 443 | HTTPS | TCP |
| 445 | SMB | TCP |
| 514 | Syslog | UDP |
| 636 | LDAPS | TCP |
| 3389 | RDP | TCP |
| 1720 | H.323 | TCP |
| 5060/5061 | SIP | TCP/UDP |

## Common Exam Traps

- DNS uses TCP for zone transfers, UDP for standard queries — questions test this split.
- SNMP traps (unsolicited) come from the agent on 162; polling goes to 161.

## Related

- [[OSI Model MOC]]
- [[TCP vs UDP]]
