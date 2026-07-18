---
title: "Web Request Auditing and Header Checks"
difficulty: medium
tags:
  - medium
  - security
  - web
---

# Web Request Auditing and Header Checks

`🟡 MEDIUM` #medium

## What it covers
Using [[Working with APIs (requests)]] to check for missing/misconfigured security headers on a target you own.

## Key points
- Headers to check: `Content-Security-Policy`, `X-Frame-Options`, `Strict-Transport-Security`
- This is a real, legal, useful habit — many bug bounty recon scripts start exactly here
- Combine with [[Web Scraping (BeautifulSoup)]] to also flag forms without CSRF tokens

## Practice
Write a script that takes a list of your own domains and reports which security headers are missing.


## Related
- [[Working with APIs (requests)]]
- [[Web Scraping (BeautifulSoup)]]
