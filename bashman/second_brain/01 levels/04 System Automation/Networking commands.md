---
tags: [bash-course, concept, level-04]
level: "[[04 System Automation]]"
---

# Networking commands

> Bash provides several tools to inspect and test network connectivity and configuration directly from the command line.

## Syntax
```bash
ping, ip addr, netstat / ss, traceroute
```

## Example
```bash
$ ip addr show | grep inet
```

## Expected output
```
inet 127.0.0.1/8 scope host lo
inet 192.168.1.42/24 brd 192.168.1.255
```

## ⚠️ Common mistake
Relying on outdated commands like ifconfig or netstat on modern systems where ip and ss have effectively replaced them.

## 💡 Practical use
Basic networking commands are the first diagnostic step for connectivity issues and a starting point for authorized reconnaissance.

## Notes

## Related
- [[04 System Automation]]
- [[Bash Cheat Sheet]]
