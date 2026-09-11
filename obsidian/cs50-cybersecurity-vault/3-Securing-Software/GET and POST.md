---
tags: [week3, concept]
---

# GET and POST

Two HTTP request methods with different intended semantics:

- **GET** — intended for retrieving data, with parameters visible in the
  URL. Should be safe to repeat and should never cause a state change
  (side effect) on the server, by convention.
- **POST** — intended for submitting data / causing a state change, with
  parameters in the request body rather than the URL.

Security relevance: if a state-changing action (delete account, transfer
money) is implemented as a GET request, it becomes trivially triggerable
via a simple link or embedded image — exactly the shape
[[Cross-Site Request Forgery CSRF]] exploits. Using POST for state
changes (combined with CSRF tokens) is a baseline defense, since a forged
cross-origin POST is at least somewhat harder to trigger than a bare
link, though POST alone doesn't fully stop CSRF on its own.

Up: [[3 Securing Software MOC]]
