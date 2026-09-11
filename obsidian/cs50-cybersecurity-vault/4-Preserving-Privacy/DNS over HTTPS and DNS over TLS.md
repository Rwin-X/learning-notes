---
tags: [week4, concept, defense]
aliases: [DoH, DoT, DNS over HTTPS, DNS over TLS]
---

# DNS over HTTPS (DoH) and DNS over TLS (DoT)

Two protocols that encrypt [[DNS Privacy|DNS]] lookups, closing the gap
where plain DNS would otherwise reveal every domain visited in plaintext
to network observers, even when the site itself is reached over
[[HTTP vs HTTPS|HTTPS]].

- **DoT**: DNS queries wrapped in [[TLS]], on a dedicated port — easy for
  a network to identify and selectively block as DNS traffic specifically,
  since it's distinguishable from other traffic on the wire.
- **DoH**: DNS queries sent as ordinary [[HTTPS]] traffic, blending in
  with regular web traffic on the standard HTTPS port — harder to
  selectively identify or block without blocking HTTPS broadly.

Same tradeoff shape as elsewhere in the course
([[Security as a Tradeoff]]): encrypting DNS improves privacy from local
network observers, but shifts trust to whichever DNS resolver is chosen
— that resolver still sees every lookup, so *which* provider you point
DoH/DoT at matters as much as using it at all.

Up: [[4 Preserving Privacy MOC]]
