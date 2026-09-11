---
tags: [week1, concept, defense]
---

# End-to-End Encryption

Only the sender and the intended recipient can read the message content —
not even the service relaying it in between (e.g. the messaging app's own
servers) can decrypt it. Built on [[Public-Key Cryptography]]: each
participant has a key pair, and messages are encrypted specifically to
the recipient's public key.

Stronger guarantee than ordinary encryption-in-transit (see
[[Encryption in Transit vs at Rest]]), where the *server itself* might be
able to decrypt traffic even though an outside eavesdropper can't. E2EE
removes the server as a point of access entirely, which matters directly
for [[4 Preserving Privacy MOC|preserving privacy]] against both outside
attackers and the service provider itself.

Up: [[1 Securing Data MOC]]
