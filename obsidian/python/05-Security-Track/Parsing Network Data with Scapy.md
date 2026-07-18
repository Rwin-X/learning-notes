---
title: "Parsing Network Data with Scapy"
difficulty: hard
tags:
  - hard
  - security
  - networking
---

# Parsing Network Data with Scapy

`🟠 HARD` #hard

## What it covers
Using `scapy` to craft, sniff, and parse packets — the library behind your NetViz/PacketForge projects.

## Key points
- `scapy.all.sniff(prn=callback)` for live capture; `rdpcap()` to read a `.pcapng` file offline
- Layered packet construction: `IP()/TCP()/Raw()` stacks layers with `/`
- Always sniff on interfaces/networks you're authorized to monitor

## Practice
Write a script that reads a `.pcapng` file and reports the top 5 talker IPs by packet count.


## Related
- [[Working with Sockets]]
- [[Working with Log Parsing]]
