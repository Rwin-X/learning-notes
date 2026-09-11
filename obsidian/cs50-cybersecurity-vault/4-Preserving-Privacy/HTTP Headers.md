---
tags: [week4, concept]
---

# HTTP Headers

Metadata sent along with every HTTP(S) request and response, separate
from the actual page content. Several carry real privacy implications:

- **User-Agent** — identifies browser, version, and operating system;
  contributes to [[Fingerprinting]].
- **Referer** — tells the destination site which page linked to it,
  potentially leaking what you were previously viewing (including
  sensitive URLs that embed information in the URL itself).
- Cookie-related headers — carry [[Session Cookies vs Tracking Cookies]]
  back and forth on every request.

These are visible to the server on every request regardless of
[[HTTP vs HTTPS|HTTPS]] — encryption hides content and headers from
outside observers in transit, but the *destination server itself* always
sees them, by design, since it needs them to respond correctly.

Up: [[4 Preserving Privacy MOC]]
