---
domain: Troubleshooting
status: 🔲
tags: [network-plus, troubleshooting, dhcp, dns]
---

# Common Network Service Issues

## DHCP Issues

| Symptom | Likely Cause |
|---|---|
| Client has 169.254.x.x address | APIPA — DHCP server unreachable or not responding |
| Client gets wrong subnet/gateway | Rogue DHCP server, wrong scope config |
| Client can't get an address at all | Scope exhausted, DHCP relay/helper misconfigured across subnets |

## DNS Issues

| Symptom | Likely Cause |
|---|---|
| Can ping by IP but not hostname | DNS resolution failure |
| Wrong site loads for a domain | DNS poisoning/cache corruption, hosts file entry |
| Intermittent name resolution | DNS server unreachable/overloaded, TTL/cache issues |

## Routing/Connectivity Issues

| Symptom | Likely Cause |
|---|---|
| Can reach local subnet, not remote | Default gateway misconfigured/down |
| Asymmetric routing issues | Multiple paths, routing table inconsistency |
| High latency on one hop | Congestion or misconfigured QoS at that hop (visible via traceroute) |

## Common Exam Traps

- APIPA (169.254.x.x) always points to DHCP failure — this is one of the most reliable symptom-to-cause mappings on the exam.
- "Ping IP works, ping hostname fails" is always a DNS problem, not a connectivity problem — don't overthink it.

## Related

- [[Network Services]]
- [[CLI Tools Reference]]
