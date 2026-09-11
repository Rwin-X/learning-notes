---
tags: [week3, concept, defense]
---

# Character Escapes

Converting characters with special meaning in a target context (HTML,
SQL, shell commands) into a form that's displayed/stored literally rather
than interpreted as syntax. E.g. `<` becomes `&lt;` in HTML output, so a
user-submitted `<script>` tag renders as visible text instead of
executing.

The primary defense against [[Cross-Site Scripting XSS]] when applied
consistently at every point untrusted data is *output* into a page —
missing even one output location reopens the vulnerability. For
[[SQL Injection]], the more robust equivalent is
[[Prepared Statements]] rather than manual escaping, since manual SQL
escaping is easy to get subtly wrong.

Up: [[3 Securing Software MOC]]
