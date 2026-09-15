
---
tags: [bash-course, level, level-04]
---

# 04 System Automation

> Permissions, processes, scheduling, and networking — the operational layer that turns scripts into real infrastructure you can trust on a live server.

| Field | Value |
|---|---|
| Difficulty | Advanced |
| Time | ~6–9 hours |
| Skills gained | permissions, processes, cron, networking, debugging |
| Prerequisites | Levels 01–03 |
| Final challenge | Detect and report on a named process |

## Concepts

- [[File permissions]] — Every file has three permission sets — owner, group, others — each with read, write, and execute bits, shown as rwx in ls -l output.
- [[chmod]] — chmod changes a file's permissions, either symbolically (u+x) or numerically (755), where each digit represents owner/group/others.
- [[chown]] — chown changes the owner (and optionally group) of a file or directory. It typically requires root privileges to change ownership to another user.
- [[Users and groups]] — Linux organizes access control around users and groups. Every process runs as a user, and group membership grants shared access to resources.
- [[Processes]] — A process is a running instance of a program, identified by a unique PID (process ID). Every command you run becomes a process while active.
- [[ps]] — ps lists running processes. ps aux is the most common form, showing all processes system-wide with owner, CPU, and memory usage.
- [[top]] — top shows a live, auto-refreshing view of running processes ranked by resource usage — the go-to tool for real-time system monitoring.
- [[kill]] — kill sends a signal to a process by PID, most commonly to terminate it. The default signal (SIGTERM) asks the process to shut down gracefully.
- [[Signals]] — Signals are how the OS communicates with processes: SIGTERM asks for graceful shutdown, SIGKILL forces immediate termination, SIGHUP often means reload config.
- [[Background processes]] — Appending & runs a command in the background, returning control of the terminal immediately instead of waiting for it to finish.
- [[Jobs]] — jobs lists background and suspended processes started from the current shell session, along with their job numbers.
- [[Cron]] — cron runs scheduled commands automatically at specified times, defined in a crontab file using a five-field time syntax.
- [[System monitoring]] — System monitoring means regularly checking resource usage — CPU, memory, disk, network — to catch problems before they cause outages.
- [[Logs]] — Logs are timestamped records of what a system or application did, typically stored under /var/log, and are the primary evidence trail for debugging and investigations.
- [[Networking commands]] — Bash provides several tools to inspect and test network connectivity and configuration directly from the command line.
- [[curl]] — curl transfers data to or from a URL, and is the standard tool for testing APIs, downloading files, and checking web service status from a script.
- [[wget]] — wget downloads files from the web, with strong support for resuming interrupted downloads and recursive fetching — well suited to unattended scripts.
- [[SSH]] — SSH provides encrypted remote access to another machine's shell, and underlies most remote administration and automation workflows.
- [[Automation]] — Automation means encoding a repeatable manual process into a script so it runs identically every time, without human error or fatigue.
- [[Bash debugging]] — Bash scripts can be debugged by tracing execution, checking syntax without running, and adding strict error-handling flags at the top of the script.
- [[set -x]] — set -x turns on command tracing inside a running script, printing each command (with expanded variables) before it executes — and set +x turns it back off.
- [[Error handling]] — Bash scripts should explicitly handle failure — checking exit codes, using set -e to stop on errors, and cleaning up with trap when things go wrong.
- [[Bash security best practices]] — Writing secure Bash means quoting variables, validating input, avoiding eval on untrusted data, and using least-privilege permissions throughout.
