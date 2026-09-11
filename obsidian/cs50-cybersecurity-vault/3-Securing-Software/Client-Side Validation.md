---
tags: [week3, concept]
---

# Client-Side Validation

Checking user input (format, required fields, length) in the browser,
before it's ever sent to the server — good for user experience (instant
feedback, no round-trip needed), but *not* a security boundary.

Anyone can bypass it entirely — disable JavaScript, use
[[Developer Tools]] to edit the page, or send requests directly with a
tool like curl, skipping the browser altogether. Relying on client-side
validation *as* security is a common, serious mistake: the real
enforcement has to happen in [[Server-Side Validation]], since the server
is the only party that can't be tampered with by the client.

Up: [[3 Securing Software MOC]]
