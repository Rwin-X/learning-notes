
---
domain: Implementation
status: 🔲
tags: [network-plus, dhcp, dns]
---

# Network Services

## DHCP

Process = **DORA**: Discover → Offer → Request → Acknowledge

- **Scope**: range of IPs the server can lease.
- **Lease time**: how long a client holds an address.
- **Reservation**: static IP tied to a MAC address within DHCP.
- **Exclusion**: IPs in the scope range that DHCP won't hand out.
- **DHCP relay/IP helper**: forwards DHCP broadcasts across subnets/routers.

## DNS

- **A record**: hostname → IPv4.
- **AAAA record**: hostname → IPv6.
- **CNAME**: alias to another hostname.
- **MX record**: mail server, includes priority.
- **TXT record**: arbitrary text (SPF, DKIM, verification).
- **NS record**: authoritative name servers.
- **PTR record**: reverse lookup (IP → hostname).
- **SOA record**: zone authority info, serial number, refresh/retry timers.

Recursive vs iterative queries: recursive = resolver does all the work and returns final answer; iterative = each server refers to the next.

## NTP

- Synchronizes time across devices — critical for logging, certificates (TLS), and Kerberos auth (5-minute clock skew tolerance).

## Common Exam Traps

- DORA order is a guaranteed test item — know it cold.
- MX record priority: **lower number = higher priority**.
- PTR records live in reverse lookup zones (in-addr.arpa) — commonly confused with A records.

## Related

- [[Ports and Protocols]]
