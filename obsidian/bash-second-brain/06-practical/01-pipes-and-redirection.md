---
tags: [practical, bash]
aliases: [pipes, redirection, stdin stdout stderr]
---

# Pipes & Redirection

This is the practical, hands-on expansion of the streams concept
introduced in [[02-io-and-flow/01-input-output|Input & Output]].

## Pipes (`|`) — chaining programs

A pipe sends the **stdout** of one command directly into the **stdin**
of the next, without touching disk:

```bash
ps aux | grep firefox                  # filter process list
cat access.log | grep "404" | wc -l    # count 404 errors in a log
history | tail -20                      # last 20 commands
```

## Redirection Operators

| Operator | Effect |
|---|---|
| `>` | Redirect stdout, **overwrite** file |
| `>>` | Redirect stdout, **append** to file |
| `2>` | Redirect stderr only |
| `2>>` | Append stderr |
| `&>` | Redirect BOTH stdout and stderr, overwrite |
| `&>>` | Redirect BOTH, append |
| `<` | Redirect a file's content INTO a command's stdin |
| `2>&1` | Redirect stderr to wherever stdout is currently going |

```bash
echo "log entry" >> app.log            # append, don't overwrite
grep "error" app.log > errors.txt 2>&1  # capture matches AND any grep errors
command < input.txt                     # feed file content as stdin
```

⚠️ Order matters with `2>&1`:
```bash
command > out.txt 2>&1     # CORRECT: stdout→file, then stderr follows stdout→file
command 2>&1 > out.txt     # WRONG: stderr→terminal (stdout's old target), THEN stdout→file
```

## Discarding Output

```bash
command > /dev/null 2>&1    # silence everything — common in cron jobs / health checks
command 2> /dev/null         # silence errors only, keep normal output visible
```

## `tee` — Write to a File AND Keep It Flowing

```bash
echo "hello" | tee output.txt          # writes to file AND prints to screen
command | tee -a log.txt | grep "err"   # -a = append; also pipes onward to grep
```

## Process Substitution — feeding a command's output as if it were a file

```bash
diff <(sort file1.txt) <(sort file2.txt)
```
`<(...)` runs the command and presents its output as a temporary
file-like path — useful when a tool expects a filename argument but
you only have a command's output.

## Here-Documents and Here-Strings

```bash
cat << EOF
Multi-line
text block
EOF

grep "pattern" <<< "$variable"    # here-string: feed a variable as stdin directly
```

---

## Links
- Previous: [[05-file-and-system/03-process-basics]]
- Next: [[02-common-utilities]]
- Related: [[02-io-and-flow/01-input-output|Input & Output]], [[02-io-and-flow/03-loops|Loops]]
- Hub: [[00-MOC]]
