---
tags: [week3, attack]
aliases: [CSRF, Cross-Site Request Forgery]
---

# Cross-Site Request Forgery (CSRF)

Tricks a victim's *browser* into making a request to a site the victim is
already logged into, without the victim intending it — e.g. a malicious
page contains a hidden form that auto-submits a "transfer funds" or
"change email" request to a bank the victim happens to be logged into,
using the browser's already-valid session
[[Session Hijacking and Cookies|cookie]] automatically.

Different attack shape from [[Cross-Site Scripting XSS]]: XSS runs
attacker script *inside* the trusted site; CSRF forges a request *to* the
trusted site *from* an entirely different, malicious page, relying on the
browser automatically attaching cookies to same-origin-looking requests.

Relevant here: the distinction between [[GET and POST]] requests, since
state-changing actions should never be triggerable via a simple GET link.
Primary defense: CSRF tokens — a unique, unpredictable value embedded in
legitimate forms that a forged cross-site request can't know or include.

Up: [[3 Securing Software MOC]]
