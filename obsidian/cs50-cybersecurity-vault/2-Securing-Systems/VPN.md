---
tags: [week2, week4, concept, defense]
aliases: [VPN]
---

# VPN (Virtual Private Network)

Encrypts traffic between your device and a VPN server, then that server
forwards traffic onward to its actual destination. Protects traffic from
[[Packet Sniffing]] on the local network (e.g. public Wi-Fi) and hides
your IP address from the final destination, which sees the VPN server's
IP instead of yours.

Important limit: it shifts *who* can see your traffic, it doesn't
eliminate visibility entirely — the VPN provider itself can see
everything a local network attacker otherwise could, which is why VPN
provider trust and logging policy matter as much as the encryption. This
becomes central again in [[4 Preserving Privacy MOC]].

Distinct from [[SSH]] (remote command-line access to a specific machine)
and from [[HTTPS]] (encrypts one connection to one site, not all
traffic).

Up: [[2 Securing Systems MOC]]
