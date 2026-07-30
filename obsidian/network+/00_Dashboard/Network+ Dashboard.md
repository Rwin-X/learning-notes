---
tags: [dashboard, network-plus]
cssclasses: [dashboard]
---

# Network+ (N10-009) — Cert Dashboard

> Exam: 90 questions max, 90 minutes, pass score 720/900. PBQs included.

## Domain Weights

| Domain | Weight | Status |
|---|---|---|
| [[Networking Concepts MOC\|1.0 Networking Concepts]] | 23% | 🔲 |
| [[Implementation MOC\|2.0 Implementation]] | 20% | 🔲 |
| [[Operations MOC\|3.0 Operations]] | 19% | 🔲 |
| [[Security MOC\|4.0 Security]] | 14% | 🔲 |
| [[Troubleshooting MOC\|5.0 Troubleshooting]] | 24% | 🔲 |

Troubleshooting is the single largest domain — weight study time accordingly.

## Progress Tracker

```dataview
TABLE status as "Status", domain as "Domain"
FROM "01_Networking_Concepts" OR "02_Implementation" OR "03_Operations" OR "04_Security" OR "05_Troubleshooting"
WHERE status
SORT domain ASC
```

## Status Counts

```dataview
TABLE WITHOUT ID
  status as "Status",
  length(rows) as "Count"
FROM "01_Networking_Concepts" OR "02_Implementation" OR "03_Operations" OR "04_Security" OR "05_Troubleshooting"
WHERE status
GROUP BY status
```

## Weak Topics (flag manually after quizzes)

```dataview
LIST
FROM "01_Networking_Concepts" OR "02_Implementation" OR "03_Operations" OR "04_Security" OR "05_Troubleshooting"
WHERE contains(tags, "weak")
```

## Quick Links

- [[Port Numbers Cheatsheet]]
- [[OSI Model MOC]]
- [[Subnetting Practice]]
- [[06_Labs/Lab Index|Lab Index]]

## Study Log

| Date | Topic | Notes |
|---|---|---|
|  |  |  |
