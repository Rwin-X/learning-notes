---
domain: Implementation
status: 🔲
tags: [network-plus, wireless]
---

# Wireless Networking

## Standards

| Standard | Band | Max Speed (theoretical) |
|---|---|---|
| 802.11a | 5 GHz | 54 Mbps |
| 802.11b | 2.4 GHz | 11 Mbps |
| 802.11g | 2.4 GHz | 54 Mbps |
| 802.11n (Wi-Fi 4) | 2.4/5 GHz | 600 Mbps |
| 802.11ac (Wi-Fi 5) | 5 GHz | ~3.5 Gbps |
| 802.11ax (Wi-Fi 6) | 2.4/5 GHz | ~9.6 Gbps |
| Wi-Fi 6E | +6 GHz band | Same as Wi-Fi 6, less interference |

## Key Terms

- **SSID**: network name.
- **Channel bonding**: combining adjacent channels for more bandwidth.
- **MIMO / MU-MIMO**: multiple antennas, multiple simultaneous streams to multiple users.
- **OFDMA**: (Wi-Fi 6) splits channels into smaller resource units for multiple devices — improves efficiency in dense environments.
- **Roaming / 802.11r**: fast handoff between APs without dropping connection.

## Security Standards

| Standard | Notes |
|---|---|
| WEP | Broken, never use |
| WPA | Improved but still weak (TKIP) |
| WPA2 | AES-CCMP, still widely used |
| WPA3 | SAE handshake (replaces PSK's 4-way handshake vulnerability), current standard |

## Common Exam Traps

- 2.4 GHz = longer range, more interference, fewer non-overlapping channels (1, 6, 11).
- 5/6 GHz = shorter range, less interference, more channels.
- WPA2 vs WPA3: WPA3 fixes KRACK-style offline dictionary attacks via SAE.

## Related

- [[Security MOC]]
