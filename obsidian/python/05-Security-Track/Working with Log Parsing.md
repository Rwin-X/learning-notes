---
title: "Working with Log Parsing"
difficulty: medium
tags:
  - medium
  - security
  - parsing
---

# Working with Log Parsing

`🟡 MEDIUM` #medium

## What it covers
Turning raw logs (auth logs, web server logs, firewall logs) into structured, queryable data.

## Key points
- Combine [[Regular Expressions]] + [[Generators and Iterators]] to stream-parse huge log files without loading them fully into memory
- Common target: failed SSH login patterns, repeated 404s (scanning behavior), unusual user agents
- Output to CSV/JSON so it can feed a dashboard (like your HoneyShield PyQt6 dashboard)

## Practice
Parse an `auth.log`-style sample and count failed login attempts per source IP.


## Related
- [[Regular Expressions]]
- [[Generators and Iterators]]
- [[Logging]]
