
---
tags: [processes, bash]
aliases: [background jobs, PID, signals, kill]
---

# Process Basics

## Foreground vs Background

```bash
long_task.sh          # runs in foreground — terminal is blocked until it finishes
long_task.sh &         # runs in background — & returns control immediately
```

## Job Control

```bash
jobs              # list background jobs in this shell session
fg %1              # bring job 1 back to foreground
bg %1              # resume a stopped job in the background
```

`Ctrl+Z` suspends the current foreground job (stops it, doesn't kill
it); follow with `bg` to resume it in the background, or `fg` to
resume it in the foreground.

## Process IDs

```bash
echo $$          # PID of the current shell
echo $!          # PID of the most recently backgrounded job

command &
pid=$!
echo "Started with PID $pid"
```

## Viewing Running Processes

```bash
ps aux                    # snapshot of all processes
ps aux | grep bash         # filter for specific process names
top                          # live, interactive process viewer
htop                         # nicer live viewer (if installed)
```

## Killing Processes

```bash
kill 1234              # send SIGTERM (polite request to stop) to PID 1234
kill -9 1234            # send SIGKILL (force kill, cannot be ignored)
kill -l                   # list all available signal names
pkill -f "process_name"   # kill by matching process name/command line
```

| Signal | Number | Meaning |
|---|---|---|
| SIGTERM | 15 | "Please terminate gracefully" (default for `kill`) |
| SIGKILL | 9 | "Terminate immediately, no cleanup" (cannot be caught/ignored) |
| SIGINT | 2 | What `Ctrl+C` sends |
| SIGHUP | 1 | Terminal closed / hangup |

## Trapping Signals in a Script

You can intercept a signal and run cleanup code before exiting:

```bash
cleanup() {
    echo "Interrupted — cleaning up..."
    rm -f /tmp/tempfile
    exit 1
}

trap cleanup SIGINT SIGTERM

echo "Running... press Ctrl+C to test"
sleep 100
```
This pattern matters a lot for scripts that create temp files, hold
locks, or need to leave the system in a clean state even if
interrupted mid-run.

## Waiting for Background Jobs

```bash
task1.sh &
task2.sh &
wait          # blocks until ALL backgrounded jobs finish
echo "Both tasks complete"
```

---

## Links
- Previous: [[02-permissions]]
- Next: [[06-practical/01-pipes-and-redirection]]
- Related: [[04-functions-and-scripts/02-arguments-and-exit-codes|Exit Codes]]
- Hub: [[00-MOC]]
