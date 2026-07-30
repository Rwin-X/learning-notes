---
domain: Networking Concepts
status: 🔲
tags: [network-plus]
---

# Network Topologies and Architectures

## Physical Topologies

- **Star** — all nodes connect to central switch/hub. Most common today. Single point of failure = the hub.
- **Mesh** — every node connects to every other. Full mesh = high redundancy, high cost. Partial mesh = compromise.
- **Bus** — single backbone cable (legacy, rare now).
- **Ring** — each node connects to two neighbors (legacy, token ring).
- **Hybrid** — combination (e.g., star-of-stars in enterprise campuses).

## Architectures

- **Three-tier hierarchical**: Core → Distribution → Access layers.
- **Spine-and-leaf**: Data center standard. Every leaf switch connects to every spine switch — predictable latency, east-west traffic optimized.
- **SDN (Software-Defined Networking)**: Control plane decoupled from data plane, centralized controller.
- **SD-WAN**: Application-aware routing over multiple WAN links (MPLS, broadband, LTE) based on policy.
- **Zero Trust**: "never trust, always verify" — no implicit trust based on network location.
- **SASE (Secure Access Service Edge)**: Combines SD-WAN + security (ZTNA, SWG, CASB, FWaaS) delivered from cloud.

## Common Exam Traps

- Spine-and-leaf vs three-tier: spine-and-leaf has no distribution layer and every leaf-to-spine hop is equal latency.
- SASE and Zero Trust are heavily emphasized in N10-009 — new since N10-008.

## Related

- [[Cloud Concepts]]
