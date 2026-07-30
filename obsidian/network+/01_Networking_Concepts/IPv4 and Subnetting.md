---
domain: Networking Concepts
status: 🔲
tags: [network-plus, subnetting]
---

# IPv4 and Subnetting

See [[Subnetting Practice]] for drills.

## Address Classes (legacy but still tested)

| Class | Range | Default Mask |
|---|---|---|
| A | 1–126 | /8 (255.0.0.0) |
| B | 128–191 | /16 (255.255.0.0) |
| C | 192–223 | /24 (255.255.255.0) |
| D | 224–239 | Multicast |
| E | 240–255 | Experimental |

## Private Ranges (RFC 1918)

- 10.0.0.0/8
- 172.16.0.0/12
- 192.168.0.0/16

## CIDR Quick Reference

| CIDR | Mask | Hosts |
|---|---|---|
| /24 | 255.255.255.0 | 254 |
| /25 | 255.255.255.128 | 126 |
| /26 | 255.255.255.192 | 62 |
| /27 | 255.255.255.224 | 30 |
| /28 | 255.255.255.240 | 14 |
| /29 | 255.255.255.248 | 6 |
| /30 | 255.255.255.252 | 2 |

Formula: usable hosts = 2^(32-CIDR) - 2

## Key Facts

- 127.0.0.0/8 = loopback.
- 169.254.0.0/16 = APIPA (link-local, DHCP failure indicator).
- Subnet mask determines network vs host portion of an address.

## Common Exam Traps

- APIPA address on a host = DHCP server unreachable, not a config error on the host itself — troubleshooting domain loves this.
- Broadcast address = all host bits set to 1 (last usable address is one below it).

## Related

- [[IPv6 Basics]]
- [[Subnetting Practice]]
