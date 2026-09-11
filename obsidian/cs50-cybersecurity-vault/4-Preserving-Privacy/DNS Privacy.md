---
tags: [week4, concept]
aliases: [DNS]
---

# DNS Privacy

DNS (Domain Name System) translates human-readable domain names (like
`example.com`) into IP addresses. Every site visited requires a DNS
lookup first — and traditionally, these lookups are sent in plaintext,
visible to anyone observing the network, including your ISP by default.

Privacy implication: even if the actual page content is protected by
[[HTTPS]], the *plain DNS lookup that precedes it* can still reveal
exactly which domains you're visiting to any network observer — a gap
that HTTPS alone doesn't close, since the DNS step happens before the
HTTPS connection is even established.

Fixed specifically by [[DNS over HTTPS and DNS over TLS]], which encrypt
the lookup itself.

Up: [[4 Preserving Privacy MOC]]
