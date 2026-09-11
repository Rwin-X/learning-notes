---
tags: [week4, concept, defense]
aliases: [Tor, The Onion Router]
---

# Tor

Routes traffic through multiple volunteer-run relays, each layer
encrypted so that no single relay knows both who the sender is *and*
where the traffic is ultimately going — the entry relay knows who you
are but not your destination; the exit relay knows the destination but
not who you are.

Different privacy model than a [[VPN]]: a VPN shifts trust to a single
provider who *can* see everything you'd otherwise expose to your local
network — Tor is specifically designed so no single party in the chain
has that full picture. Tradeoff (see [[Security as a Tradeoff]]):
meaningfully slower due to multi-hop routing, and the exit relay can
still see unencrypted traffic content if the destination itself isn't
using [[HTTP vs HTTPS|HTTPS]] — Tor anonymizes the *path*, it doesn't
replace end-to-end encryption of content.

Up: [[4 Preserving Privacy MOC]]
