
---
tags: [fundamentals, bash]
aliases: [Shebang, Running scripts]
---

# Shebang & Script Execution

## The Shebang Line

The first line of a script tells the OS which interpreter to use:

```bash
#!/bin/bash
```

This isn't a comment — it's a directive. `#!` is called the **shebang**
(hash + bang). Without it, the script may run under the wrong shell and
break on Bash-specific syntax.

Portable alternative (uses `env` to locate bash in `$PATH`):
```bash
#!/usr/bin/env bash
```

## Making a Script Executable

```bash
chmod +x myscript.sh   # grant execute permission
./myscript.sh          # run it (note the ./ )
```

See [[05-file-and-system/02-permissions|Permissions]] for what `chmod`
is actually changing.

## Three Ways to Run a Script — and why it matters

| Method | Effect |
|---|---|
| `./script.sh` | Runs in a **new subshell**. Variable changes don't persist to your terminal. |
| `bash script.sh` | Same — new subshell, explicit interpreter. |
| `source script.sh` or `. script.sh` | Runs in your **current shell**. Variables/functions persist afterward. |

This distinction trips up beginners constantly: if a script is supposed
to change your current directory or export a variable into your live
terminal session, you **must** `source` it — running it normally
executes in an isolated process that disappears when it finishes.

```bash
# This will NOT change your terminal's directory:
./go_home.sh

# This WILL:
source go_home.sh
```

## Exit Behavior

Every script (and every command) returns an **exit code** when it
finishes: `0` means success, anything `1–255` means some kind of
failure. This becomes critical in [[02-io-and-flow/02-conditionals|Conditionals]]
and [[04-functions-and-scripts/02-arguments-and-exit-codes|Exit Codes]].

```bash
echo "hi"
echo $?     # prints the exit code of the last command (0 = success)
```

---

## Links
- Previous: [[01-what-is-bash]]
- Next: [[03-variables]]
- Related: [[05-file-and-system/02-permissions|Permissions]], [[04-functions-and-scripts/02-arguments-and-exit-codes|Exit Codes]]
- Hub: [[00-MOC]]
