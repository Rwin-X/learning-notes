---
tags: [week2, concept]
aliases: [HTTP, HTTPS]
---

# HTTP vs. HTTPS

**HTTP** transmits web traffic in plaintext — anyone positioned between
client and server ([[Machine-in-the-Middle Attacks]]) can read or modify
it via [[Packet Sniffing]].

**HTTPS** is HTTP layered on top of [[TLS]], encrypting the traffic
end-to-end between browser and server. Uses
[[Public-Key Cryptography]] (Week 1) to establish a shared session key,
then fast [[Secret-Key Cryptography]] to actually encrypt the traffic —
the same hybrid pattern used elsewhere in cryptography.

Trust that the server is who it claims to be comes from a
[[Certificate and Certificate Authority|certificate]], not the encryption
itself — encryption alone stops eavesdropping, but without certificate
validation an attacker could still run their own HTTPS server and
impersonate the real one.

Downgrade attack to watch for: [[SSL Stripping]], which tries to keep the
connection on plain HTTP despite HTTPS being available.

Up: [[2 Securing Systems MOC]]
