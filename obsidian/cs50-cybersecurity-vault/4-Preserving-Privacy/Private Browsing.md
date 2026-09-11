---
tags: [week4, concept]
---

# Private Browsing

A browser mode that avoids saving local history, cookies, and site data
after the session ends — addresses *local* traces (see
[[Web Browsing History]]) but has real, often misunderstood limits:

- Doesn't hide activity from the network — your ISP, employer network, or
  anyone positioned to observe traffic still sees it, same as normal
  browsing (see [[Machine-in-the-Middle Attacks]], Week 0/2).
- Doesn't stop server-side [[Logs]] — visited sites still record the
  visit.
- Doesn't defeat [[Fingerprinting]] — device/browser characteristics are
  still exposed identically to normal browsing.
- Doesn't stop [[Supercookies]], which are specifically designed to
  persist outside normal cookie storage and survive exactly this kind of
  clearing.

Genuinely useful for local-device privacy (shared/public computers,
not leaving history for others with physical access); not a general
anonymity or anti-tracking tool on its own.

Up: [[4 Preserving Privacy MOC]]
