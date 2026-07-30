---
domain: Networking Concepts
status: 🔲
tags: [network-plus]
---

# IPv6 Basics

## Key Facts

- 128-bit address, 8 groups of 4 hex digits, separated by colons.
- Leading zeros in a group can be omitted; one run of consecutive all-zero groups can be replaced with `::` (only once per address).
- No broadcast — uses multicast and anycast instead.
- No NAT requirement (address space is large enough), though NAT66 exists.

## Address Types

| Type | Prefix | Purpose |
|---|---|---|
| Link-local | fe80::/10 | Auto-assigned, non-routable, same-segment only |
| Unique local | fc00::/7 | Private, like RFC 1918 equivalent |
| Global unicast | 2000::/3 | Publicly routable |
| Multicast | ff00::/8 | One-to-many |

## Key Terms

- **SLAAC**: Stateless Address Autoconfiguration — host self-assigns via router advertisement.
- **EUI-64**: method to generate interface ID from MAC address.
- **NDP (Neighbor Discovery Protocol)**: replaces ARP in IPv6.

## Common Exam Traps

- IPv6 has no broadcast — if an answer choice says "broadcast" in an IPv6 context, it's wrong.
- ARP doesn't exist in IPv6 — NDP does that job.

## Related

- [[IPv4 and Subnetting]]
