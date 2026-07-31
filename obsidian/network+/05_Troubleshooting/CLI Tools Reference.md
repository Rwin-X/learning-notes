---
domain: Troubleshooting
status: 🔲
tags: [network-plus, troubleshooting, cli]
---

# CLI Tools Reference

## Connectivity

```
ping <host>              # ICMP echo, basic reachability
traceroute / tracert     # path + hop-by-hop latency (Linux/Windows)
pathping                 # Windows: combines ping + tracert stats over time
```

## DNS

```
nslookup <host>          # basic DNS query
dig <host>                # detailed DNS query (Linux/macOS), more verbose than nslookup
```

## Interface / Config

```
ipconfig /all             # Windows: full adapter config
ip addr / ip a            # Linux: interface addresses
ifconfig                  # Linux/macOS (legacy)
ip route                  # Linux: routing table
route print                # Windows: routing table
```

## Connection State

```
netstat -an                # active connections/listening ports
ss -tuln                   # Linux modern replacement for netstat
arp -a                      # ARP cache table
```

## Packet Capture

```
tcpdump -i eth0             # Linux packet capture
Wireshark                   # GUI packet analysis
```

## Common Exam Traps

- `tracert` (Windows, ICMP-based) vs `traceroute` (Linux, UDP-based by default) — different underlying protocol, same purpose.
- `nslookup` vs `dig`: dig gives more structured/detailed output and is Linux/macOS native; nslookup is cross-platform but simpler.
- `ipconfig /flushdns` clears the DNS resolver cache — common fix for stale DNS cache issues.

## Related

- [[Troubleshooting Methodology]]
