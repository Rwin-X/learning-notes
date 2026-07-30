---
tags: [network-plus, subnetting, practice]
---

# Subnetting Practice

## Method: Magic Number

1. Take the mask octet, subtract from 256 → block size.
2. Count in block-size increments to find subnet ranges.

Example: /27 → mask octet 224 → 256-224 = 32 (block size)
Subnets: 0, 32, 64, 96, 128, 160, 192, 224

## Drills (solve, then check)

1. 192.168.1.0/26 — how many usable hosts, and what are the subnet ranges?
2. 10.10.10.50/28 — what subnet is this host in? What's the broadcast address?
3. You need 5 subnets from 172.16.0.0/24 with at least 20 hosts each — what mask do you use?
4. 192.168.5.130/25 — network address? First/last usable host?

## Answers

1. /26 = 62 usable hosts. Ranges: .0, .64, .128, .192 (block size 64).
2. Block size 16 → subnets at .0, .16, .32, .48... 50 falls in .48 subnet. Broadcast = .63.
3. Need ≥20 hosts/subnet → /27 gives 30 hosts, block size 32 → gives 8 subnets (enough for 5).
4. Block size 128 → network = 192.168.5.128, first usable = .129, last usable = .254.

## Related

- [[IPv4 and Subnetting]]
