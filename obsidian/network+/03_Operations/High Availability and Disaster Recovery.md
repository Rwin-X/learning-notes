---
domain: Operations
status: 🔲
tags: [network-plus, ha, dr]
---

# High Availability and Disaster Recovery

## Redundancy Concepts

- **Active-active**: all nodes handle traffic simultaneously.
- **Active-passive**: standby node takes over on failure.
- **NIC teaming**: multiple NICs act as one logical interface for redundancy/throughput.
- **FHRP (First Hop Redundancy Protocol)**: HSRP (Cisco), VRRP (open standard) — provides redundant default gateway.

## DR Metrics

- **RTO (Recovery Time Objective)**: how long to restore service after an outage.
- **RPO (Recovery Point Objective)**: max acceptable data loss, measured in time (how far back backups go).
- **MTTR (Mean Time To Repair)**: average time to fix a failure.
- **MTBF (Mean Time Between Failures)**: average time between failures — reliability indicator.

## Site Types

- **Hot site**: fully operational duplicate, near-instant failover.
- **Warm site**: partially equipped, some setup time needed.
- **Cold site**: bare infrastructure only, longest recovery time.

## Backup Types

- **Full**: complete copy every time.
- **Incremental**: only changes since last backup (full or incremental).
- **Differential**: only changes since last full backup.

## Common Exam Traps

- RTO = time to recover; RPO = how much data you're willing to lose — frequently swapped on the exam.
- Incremental backups are faster to create but slower to restore (need the chain); differential is the middle ground.

## Related

- [[Documentation and Diagrams]]
