---
domain: Implementation
status: 🔲
tags: [network-plus, switching]
---

# Switching Concepts

## VLANs

- Logically segments a physical network into broadcast domains.
- **Trunk port**: carries traffic for multiple VLANs (802.1Q tagging).
- **Access port**: carries traffic for a single VLAN, untagged.
- **Native VLAN**: untagged traffic on a trunk (default VLAN 1 — should be changed for security).
- **Voice VLAN**: separate VLAN for VoIP traffic, often auto-configured via CDP/LLDP.

## Spanning Tree Protocol (STP)

- Prevents Layer 2 loops in redundant switch topologies.
- **Root bridge**: elected switch (lowest bridge ID) that all paths calculate from.
- Port states: Blocking → Listening → Learning → Forwarding (or Disabled).
- **RSTP (802.1w)**: faster convergence than legacy STP.

## Port Security / Aggregation

- **Port security**: limits MAC addresses allowed on a port (mitigates MAC flooding).
- **LACP (802.3ad)**: link aggregation — bundles multiple physical links into one logical link for redundancy/throughput.
- **PoE / PoE+**: Power over Ethernet — 15.4W / 25.5W at the port respectively.

## Common Exam Traps

- Trunk vs access port mixed up on PBQs constantly — trunk = multiple VLANs tagged, access = one VLAN untagged.
- STP blocks redundant paths to prevent loops; it doesn't remove the physical link, just logically disables forwarding on it.

## Related

- [[Routing Concepts]]
