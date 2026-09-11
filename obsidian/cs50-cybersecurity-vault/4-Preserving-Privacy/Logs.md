---
tags: [week4, concept]
---

# Logs

Server-side records of requests: typically including the requester's IP
address, timestamp, the specific resource requested, status code, and
often the `Referer` and `User-Agent` values from
[[HTTP Headers]]. Every server a request touches can independently keep
its own log, regardless of what the client does locally.

This is *why* clearing [[Web Browsing History]] locally doesn't erase the
fact that a visit happened — the visited server (and potentially
intermediate servers, like an ISP or a [[VPN]] provider) may have logged
it independently, outside the user's control entirely. What a given
provider retains and for how long is a matter of policy, not something a
user can verify just by clearing their own browser.

Up: [[4 Preserving Privacy MOC]]
