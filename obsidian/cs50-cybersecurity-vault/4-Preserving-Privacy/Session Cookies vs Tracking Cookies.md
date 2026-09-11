---
tags: [week4, concept]
aliases: [Session Cookies, Tracking Cookies]
---

# Session Cookies vs. Tracking Cookies

Both are [[Session Hijacking and Cookies|cookies]] (Week 2), but serve
different purposes:

- **Session cookies** — temporary, tied to a single browsing session,
  typically used to keep a user logged in. Usually expire when the
  browser closes.
- **Tracking cookies** — persistent, long-lived, and specifically
  designed to identify a returning visitor across visits (and often
  across *sites*, if set by [[Third-Party Cookies|a third party]]) for
  advertising and analytics purposes rather than authentication.

The authentication use case from Week 2 is legitimate and largely
necessary for how the web works; the tracking use case is the privacy
concern this week focuses on — same underlying mechanism, very different
purpose and user awareness.

Up: [[4 Preserving Privacy MOC]]
