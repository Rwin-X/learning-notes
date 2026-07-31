---
domain: Security
status: 🔲
tags: [network-plus, security, attacks]
---

# Network Attacks

## Common Attack Types

- **DoS / DDoS**: overwhelm a target to deny service; distributed = multiple sources (botnet).
- **On-path (MITM)**: attacker intercepts traffic between two parties.
- **ARP spoofing/poisoning**: attacker sends fake ARP replies to redirect traffic (enables on-path attacks on LAN).
- **DNS poisoning**: corrupt DNS cache to redirect users to malicious sites.
- **VLAN hopping**: attacker gains access to traffic on a VLAN they shouldn't reach (double tagging or switch spoofing).
- **Rogue DHCP server**: unauthorized DHCP server hands out malicious config (wrong gateway/DNS).
- **Evil twin**: rogue AP mimicking a legitimate SSID to capture credentials/traffic.
- **Deauthentication attack**: forces wireless clients to disconnect, often to capture the reconnection handshake.
- **Social engineering**: phishing, pretexting, tailgating — human-targeted, not technical.

## Mitigations

| Attack | Mitigation |
|---|---|
| ARP spoofing | Dynamic ARP Inspection (DAI) |
| Rogue DHCP | DHCP snooping |
| VLAN hopping | Disable unused trunk ports, don't use VLAN 1 as native |
| MAC flooding | Port security (limit MACs per port) |
| Evil twin | Wireless IDS/IPS, certificate-based auth |

## Common Exam Traps

- DHCP snooping and Dynamic ARP Inspection (DAI) are frequently paired — snooping builds the trusted binding table that DAI checks against.
- "Rogue DHCP" vs "rogue AP" — different attack, different mitigation; don't conflate them.

## Related

- [[Network Hardening]]
