---
domain: Implementation
status: 🔲
tags: [network-plus, routing]
---

# Routing Concepts

## Routing Protocol Types

- **Distance-vector**: RIP — hop count metric, periodic full-table broadcasts, slow convergence.
- **Link-state**: OSPF — builds full topology map, faster convergence, uses areas.
- **Hybrid**: EIGRP (Cisco proprietary) — combines both approaches.
- **Path-vector**: BGP — used between autonomous systems (the Internet's backbone protocol).

## Key Terms

- **Administrative Distance (AD)**: trustworthiness of a route source. Lower = preferred. Directly connected = 0, static = 1, EIGRP = 90, OSPF = 110, RIP = 120.
- **Metric**: cost value used within a protocol to pick best path (hop count for RIP, bandwidth/delay for OSPF).
- **Convergence**: time for all routers to agree on topology after a change.
- **Default route (0.0.0.0/0)**: gateway of last resort.

## Static vs Dynamic

- **Static**: manually configured, no overhead, doesn't adapt to changes — good for small/stable networks.
- **Dynamic**: protocol-learned, adapts automatically, more overhead.

## Common Exam Traps

- AD vs Metric confusion: AD picks between different *protocols*, metric picks best path *within* a protocol.
- BGP is the only exterior gateway protocol tested — everything else (RIP/OSPF/EIGRP) is interior.

## Related

- [[Switching Concepts]]
