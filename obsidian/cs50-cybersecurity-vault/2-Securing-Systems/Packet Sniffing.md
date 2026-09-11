---
tags: [week2, attack]
---

# Packet Sniffing

Passively capturing network traffic as it passes by — on an unencrypted
Wi-Fi network, a shared network segment, or via a
[[Machine-in-the-Middle Attacks|machine-in-the-middle]] position — and
reading its contents. Purely passive; unlike an active MITM attack, the
attacker doesn't need to alter anything, just observe.

Devastating against plaintext protocols like plain [[HTTP vs HTTPS|HTTP]]
(credentials, session cookies, page content all visible) and defeated by
[[TLS]] encryption — a sniffer on an HTTPS connection sees only
ciphertext.

Also the mechanism behind capturing session cookies for
[[Session Hijacking]].

Up: [[2 Securing Systems MOC]]
