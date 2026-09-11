---
tags: [week4, concept, defense]
---

# Permissions

App- and browser-level controls over what data or hardware a given site
or application can access — camera, microphone, location, contacts,
notifications. The user-facing enforcement point for
[[Authorization]] (Week 0) applied specifically to privacy-sensitive
device capabilities rather than account data.

Practical privacy hygiene covered here: granting access only when
actually needed for the feature in use (not by default at install time),
periodically auditing which apps/sites still hold standing permissions,
and treating an unexpected permission request (a flashlight app asking
for contacts, say) as a signal worth questioning — an instance of
applying [[Threat Model]] thinking to everyday app installs, not just to
dedicated attacks.

Up: [[4 Preserving Privacy MOC]]
