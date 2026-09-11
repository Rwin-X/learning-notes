---
tags: [week2, concept]
aliases: [Certificate, Certificate Authority, CA, X.509]
---

# Certificate and Certificate Authority (CA)

A **certificate** (standardized in the **X.509** format) binds a public
key to an identity (e.g. "this key belongs to example.com") and is
digitally signed by a trusted third party — a **Certificate Authority**.

Browsers ship with a built-in list of trusted CAs. When a site presents
its certificate during the [[TLS]] handshake, the browser verifies the
CA's [[Digital Signatures|signature]] on it. This is what actually
establishes *identity* in HTTPS — encryption alone only stops
eavesdropping; the certificate is what stops an attacker from
successfully impersonating the real site.

Weak link: if a CA is compromised or issues a certificate improperly, it
can undermine trust for every site relying on that CA — a concrete
example of why the whole system depends on CAs being trustworthy
gatekeepers, not just cryptographically correct ones.

Up: [[2 Securing Systems MOC]]
