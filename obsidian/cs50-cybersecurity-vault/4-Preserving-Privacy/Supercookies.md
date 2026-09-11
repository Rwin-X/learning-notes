---
tags: [week4, concept]
---

# Supercookies

Tracking mechanisms that persist outside the normal, user-clearable
cookie storage a browser exposes — stored via alternative mechanisms
(such as browser cache artifacts, or historically, HTTP headers injected
by an ISP) specifically so that clearing ordinary cookies doesn't remove
them.

The defining trait relative to
[[Session Cookies vs Tracking Cookies|ordinary tracking cookies]]: a
standard "clear cookies" action, and even [[Private Browsing]] in some
cases, doesn't reliably remove them, because they don't live in the
storage location those actions target. This is part of why privacy tools
increasingly focus on blocking tracking *behavior and scripts* outright,
rather than relying solely on clearing storage after the fact.

Up: [[4 Preserving Privacy MOC]]
