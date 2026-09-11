---
tags: [week4, concept]
---

# Fingerprinting

Identifying and tracking a specific device/browser using the combination
of its characteristics — screen resolution, installed fonts, browser and
OS version (from [[HTTP Headers]]), timezone, installed plugins, and
more — without needing any cookie at all. Individually common attributes
become identifying in combination, since the specific *combination* is
often unique or near-unique to one device.

This is exactly why fingerprinting is harder to defend against than
cookie-based tracking: [[Private Browsing]] and clearing cookies don't
touch it, because there's no stored file being read — the "identity" is
reconstructed fresh from characteristics the browser exposes on every
visit, by design, for compatibility. Reducing exposed characteristics
(uncommon browser settings, certain privacy-focused browsers deliberately
standardizing fingerprintable values across all their users) is the
practical countermeasure.

Up: [[4 Preserving Privacy MOC]]
