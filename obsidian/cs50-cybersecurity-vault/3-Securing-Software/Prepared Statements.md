---
tags: [week3, concept, defense]
---

# Prepared Statements

A way of executing database queries where the query's *structure* is
compiled first, separately from the *data* that fills its parameters. The
database driver sends the query template and the user-supplied values as
distinct entities, so no value — however crafted — can be interpreted as
part of the query's syntax.

The standard, reliable fix for [[SQL Injection]] — more robust than
manually escaping special characters ([[Character Escapes]]), because
escaping requires the developer to correctly anticipate every dangerous
character and context, while prepared statements make the distinction
structural rather than pattern-matched.

Up: [[3 Securing Software MOC]]
