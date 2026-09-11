---
tags: [week4, concept]
---

# Tracking Parameters

Extra data appended to a URL's query string — e.g. `utm_source`,
`utm_campaign`, or per-click identifiers — used to attribute a visit to a
specific link, campaign, or individual recipient, without needing a
cookie at all. Commonly seen in marketing emails and shared social links.

Privacy implication: the URL itself becomes a unique, traceable
identifier, and it travels wherever the link is shared or forwarded —
including potentially leaking into a
[[HTTP Headers|Referer header]] when clicked, passing the tracking
information on to whatever site the link led to. Some privacy-focused
browsers and extensions strip known tracking parameters automatically
before the request is even sent.

Up: [[4 Preserving Privacy MOC]]
