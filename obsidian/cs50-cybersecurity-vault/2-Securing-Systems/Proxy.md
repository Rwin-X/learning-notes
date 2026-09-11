---
tags: [week2, concept]
---

# Proxy

An intermediary server that sits between a client and the destination it
wants to reach, forwarding requests on the client's behalf. The
destination sees the proxy's connection, not the original client's
directly.

Overlaps in purpose with a [[VPN]] (both can hide the client's origin),
but typically operates at the application level (e.g. just web traffic)
rather than encrypting and tunneling *all* device traffic the way a VPN
does. Also used defensively in the other direction — a reverse proxy
sitting in front of a server can filter/inspect incoming requests, acting
similarly to a [[Firewall]] at the application layer.

Up: [[2 Securing Systems MOC]]
