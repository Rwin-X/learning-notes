---
tags: [week0, week2, attack]
aliases: [MITM, Man-in-the-Middle]
---

# Machine-in-the-Middle Attacks

An attacker secretly positions themselves between two communicating
parties, able to observe and potentially alter traffic that each side
believes is going directly to the other.

In Week 0's context: an attacker between a user and a login page can
capture credentials in transit if the connection isn't encrypted.

Full treatment (network-level mechanics, [[Packet Sniffing]],
[[Session Hijacking]], how [[HTTPS]]/[[TLS]] defeat it) is in Week 2 — see
[[2 Securing Systems MOC]]. The core defense is always the same:
authenticated encryption end-to-end, so an in-the-middle party sees only
ciphertext and can't convincingly impersonate either side.

Up: [[0 Securing Accounts MOC]] · Full treatment: [[2 Securing Systems MOC]]
