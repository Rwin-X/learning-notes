---
domain: Security
status: 🔲
tags: [network-plus, security, hardening]
---

# Network Hardening

## Devices/Techniques

- **Firewall (stateful vs stateless)**: stateful tracks connection state, stateless filters packet-by-packet with no context.
- **NGFW (Next-Gen Firewall)**: application-aware, integrates IDS/IPS, deep packet inspection.
- **IDS vs IPS**: IDS detects and alerts (out-of-band, passive); IPS detects and blocks (inline, active).
- **UTM (Unified Threat Management)**: all-in-one appliance (firewall + IDS/IPS + AV + content filtering).
- **Proxy server (forward/reverse)**: forward = client-side, hides internal clients; reverse = server-side, hides internal servers, load balances.
- **VPN types**: site-to-site (network-to-network), client-to-site/remote access (user-to-network).
- **DMZ**: segmented network zone for public-facing services, isolated from internal LAN.

## Hardening Practices

- Disable unused ports/services.
- Change default credentials.
- Patch management / firmware updates.
- Network segmentation (VLANs, subnets) to limit blast radius.
- ACLs (Access Control Lists) — explicit deny at the end (implicit deny all).

## Common Exam Traps

- IDS is passive/out-of-band (can alert but not stop); IPS is active/inline (can actually block traffic) — this distinction is a guaranteed test item.
- ACLs process top-down, first match wins — order matters on PBQs.

## Related

- [[Security Concepts]]
- [[Network Attacks]]
