---
tags: [week3, concept]
---

# Developer Tools

Built-in browser features letting anyone inspect and modify a page's
HTML/CSS/JavaScript live, view network requests, and execute arbitrary
JavaScript in the page's console. Legitimate and essential for
development and debugging — but also exactly what makes
[[Client-Side Validation]] trivially bypassable: a user can edit a
disabled form field, remove a `maxlength` attribute, or fire a request
directly, all without writing any code of their own.

The existence of Developer Tools is itself the practical argument for why
[[Server-Side Validation]] must be the real enforcement point — anything
enforced only in the browser is, by design, editable by whoever's using
that browser.

Up: [[3 Securing Software MOC]]
