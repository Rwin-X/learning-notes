---
tags: [week2, concept]
aliases: [WPA, Wi-Fi Security]
---

# Wi-Fi Protected Access (WPA)

Encrypts traffic between a device and a wireless access point, so nearby
parties can't trivially read it over the air the way they could with an
open/unencrypted network. Successive versions (WPA, WPA2, WPA3) have
fixed weaknesses found in earlier ones via [[Cryptanalysis]]-style
research — a reminder that "encrypted Wi-Fi" isn't a single static
guarantee, the specific protocol version matters.

Without it, traffic on the wireless hop is exposed to
[[Packet Sniffing]] by anyone in range, regardless of what encryption
exists further up the stack (like [[HTTPS]]) — though HTTPS would still
protect the actual content even over an open Wi-Fi network, layering
matters here (see [[Defense in Depth]]).

Up: [[2 Securing Systems MOC]]
