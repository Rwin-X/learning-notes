---
domain: Troubleshooting
status: 🔲
tags: [network-plus, troubleshooting, security]
---

# Common Security-Related Network Issues

## Symptoms → Likely Cause

| Symptom | Likely Cause |
|---|---|
| Sudden unexplained traffic spike | Possible DoS/DDoS, malware beaconing |
| Users redirected to wrong sites | DNS poisoning, rogue DHCP handing out bad DNS |
| Duplicate IP address errors | Rogue DHCP server or static IP conflict |
| Unauthorized device on network | Rogue AP, unused port not disabled, weak port security |
| VPN users can't reach internal resources | Split tunneling misconfig, ACL blocking VPN subnet |

## Common Exam Traps

- Duplicate IP address error can come from a rogue DHCP server OR a manually misconfigured static IP — the exam expects you to consider both.
- Sudden traffic spikes get framed as "is this a security issue or a legit demand spike" — check the troubleshooting methodology (gather info first) rather than assuming attack.

## Related

- [[Network Attacks]]
- [[Common Network Service Issues]]
