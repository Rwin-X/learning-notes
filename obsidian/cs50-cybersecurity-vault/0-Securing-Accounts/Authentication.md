---
tags: [week0, concept]
---

# Authentication

Proving *who you are*. Distinct from [[Authorization]], which is what
you're *allowed to do* once identity is established — a logged-in user is
authenticated, but authorization decides whether they can read another
user's data.

Classic factor: something you know ([[Usernames and Passwords|a password]]).
Stronger systems combine factors — see [[Multi-Factor Authentication Factors]].

Weak authentication is what [[Dictionary Attacks]], [[Brute-Force Attacks]],
and [[Credential Stuffing]] all attack directly. Strengthening it is the
point of [[Two-Factor Authentication 2FA]], [[Passkeys]], and
[[Single Sign-On SSO]].

Up: [[0 Securing Accounts MOC]]
