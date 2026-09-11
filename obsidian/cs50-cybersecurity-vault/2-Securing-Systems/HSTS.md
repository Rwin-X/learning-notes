---
tags: [week2, concept, defense]
aliases: [HSTS, HTTP Strict Transport Security]
---

# HSTS (HTTP Strict Transport Security)

A response header a site sends telling the browser: "always connect to me
over HTTPS from now on, never plain HTTP, for the next N seconds." Once a
browser has seen this header for a site, it refuses to make plain-HTTP
requests to it even if a user types `http://` or an attacker tries to
force a downgrade.

Directly closes the window [[SSL Stripping]] exploits — there's no
initial plain-HTTP request left for an attacker to intercept, for return
visits. First-ever visit to a site is still a gap (before the browser has
seen the header), which is why browsers also maintain "HSTS preload"
lists of sites known to require HTTPS from the very first connection.

Up: [[2 Securing Systems MOC]]
