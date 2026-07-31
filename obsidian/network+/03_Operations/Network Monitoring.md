---
domain: Operations
status: 🔲
tags: [network-plus, monitoring]
---

# Network Monitoring

## Tools/Protocols

- **SNMP**: polls devices for stats (v1/v2c unencrypted community strings, v3 adds auth/encryption).
- **Syslog**: centralized logging, severity levels 0 (emergency) – 7 (debug).
- **NetFlow / sFlow / IPFIX**: traffic flow analysis, who's talking to whom and how much.
- **Packet capture (tcpdump/Wireshark)**: full packet inspection.
- **SIEM**: aggregates and correlates logs across the environment for security analysis.

## Key Metrics

- **Bandwidth vs throughput**: bandwidth = theoretical max, throughput = actual achieved.
- **Latency**: delay in delivery.
- **Jitter**: variation in latency (kills VoIP/video quality).
- **Packet loss**: % of packets that don't arrive.

## Baselines

- Establish normal performance/traffic patterns first — anomalies only mean something relative to a baseline.

## Common Exam Traps

- SNMPv3 is the only version tested as "secure" — v1/v2c send community strings in cleartext.
- Syslog severity: **lower number = more severe** (0 = emergency, 7 = debug) — commonly reversed by test-takers.

## Related

- [[Documentation and Diagrams]]
