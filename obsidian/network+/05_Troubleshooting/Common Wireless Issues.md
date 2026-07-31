
---
domain: Troubleshooting
status: 🔲
tags: [network-plus, troubleshooting, wireless]
---

# Common Wireless Issues

## Symptoms → Likely Cause

| Symptom | Likely Cause |
|---|---|
| Weak signal at edge of coverage | AP placement, need repeater/additional AP |
| Slow speeds despite strong signal | Channel congestion, interference from other APs/devices |
| Frequent disconnects | Interference, roaming issues, low signal, overlapping SSIDs |
| Can't connect at all | Wrong password, MAC filtering, capacity/client limit reached |
| Signal present, no internet | Captive portal not completed, DNS/DHCP issue, AP backhaul down |

## Key Terms

- **RSSI**: received signal strength indicator — more negative = weaker (e.g., -90 dBm is weak, -50 dBm is strong).
- **Channel overlap**: using non-standard/overlapping channels on 2.4GHz causes interference (stick to 1/6/11).
- **Co-channel interference**: multiple APs on the *same* channel competing for airtime.
- **Absorption/reflection**: physical materials (concrete, metal) degrade signal.
- **Captive portal**: authentication webpage before granting full network access (common in guest wifi).

## Common Exam Traps

- "Signal is strong but throughput is bad" → almost always channel congestion or co-channel interference, not signal strength.
- 2.4GHz travels further through walls but has fewer clean channels — a "long range but slow" scenario often points here.

## Related

- [[Wireless Networking]]
