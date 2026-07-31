---
domain: Troubleshooting
status: 🔲
tags: [network-plus, troubleshooting, cabling]
---

# Common Cable and Physical Issues

## Symptoms → Likely Cause

| Symptom | Likely Cause |
|---|---|
| Intermittent connectivity | Bad cable, loose connector, EMI |
| No link light | Bad cable, wrong port, disabled port |
| Slow throughput despite good link | Duplex mismatch, wrong cable category for speed |
| Crosstalk/interference | Cable run too close to power lines, untwisted pairs (bad termination) |
| Attenuation | Cable run exceeds max distance |
| Wrong pinout | TX/RX reversed — no link or garbled data |

## Key Terms

- **Attenuation**: signal weakens over distance.
- **Crosstalk**: signal bleeds between adjacent wire pairs.
- **EMI (Electromagnetic Interference)**: external interference from motors, fluorescent lights, power lines.
- **dB loss**: measured signal loss, used in fiber testing.
- **Duplex mismatch**: one side full-duplex, other half-duplex — causes collisions/slow performance without dropping the link entirely.

## Tools

- **Cable tester**: verifies continuity/wiremap.
- **TDR (Time Domain Reflectometer)**: locates the exact break point in a copper cable.
- **OTDR**: fiber equivalent of TDR.
- **Toner probe**: traces a specific cable through a bundle/wall.
- **Light meter / OLTS**: measures fiber signal loss.

## Common Exam Traps

- Duplex mismatch is a classic "link is up but performance is terrible" scenario — don't jump to "bad cable" when the link light is on and stable.
- TDR = copper, OTDR = fiber. Exam tests you know which tool for which medium.

## Related

- [[Cabling and Transceivers]]
