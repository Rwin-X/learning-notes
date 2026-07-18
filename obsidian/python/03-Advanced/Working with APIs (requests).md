---
title: "Working with APIs (requests)"
difficulty: hard
tags:
  - hard
  - networking
  - advanced
  - web
---

# Working with APIs (requests)

`🟠 HARD` #hard

## What it covers
HTTP requests via the `requests` library: GET/POST, headers, auth, sessions.

## Key points
- Use a `requests.Session()` to persist cookies/headers across multiple calls
- Always check `response.status_code` and handle non-200s
- Set `timeout=` on every request — same reasoning as socket timeouts

## Practice
Write a script that checks a list of URLs for a specific HTTP header (e.g. missing `Content-Security-Policy`) — a real, tiny security-audit habit.


## Related
- [[Working with JSON and CSV]]
- [[Concurrency - Asyncio]]
- [[Web Scraping (BeautifulSoup)]]
