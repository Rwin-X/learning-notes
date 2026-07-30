---
domain: Networking Concepts
status: 🔲
tags: [network-plus]
---

# Cabling and Transceivers

## Copper

| Cable | Max Speed | Max Distance |
|---|---|---|
| Cat5e | 1 Gbps | 100m |
| Cat6 | 1 Gbps (10 Gbps up to 55m) | 100m |
| Cat6a | 10 Gbps | 100m |
| Cat7/8 | 10-40 Gbps | 100m/30m |

- **Straight-through**: host-to-switch.
- **Crossover**: host-to-host, switch-to-switch (legacy — modern NICs auto-MDIX).
- **T568A vs T568B**: wiring standards, differ in orange/green pair order.

## Fiber

- **Single-mode (SMF)**: long distance (10km+), laser source, yellow jacket.
- **Multi-mode (MMF)**: shorter distance (~550m-2km), LED/VCSEL source, orange/aqua jacket.

## Transceivers

- **SFP / SFP+**: 1G / 10G small form-factor pluggable.
- **QSFP / QSFP+**: 40G quad SFP.
- **QSFP28**: 100G.
- Connector types: LC (small, common), SC (older, square), ST (bayonet, legacy).

## Common Exam Traps

- Cat6 can hit 10 Gbps but only up to 55m — distance-limited, not speed-limited on paper specs.
- Matching transceiver to fiber type (SMF needs single-mode-rated optic) is a frequent PBQ.

## Related

- [[Network Topologies]]
