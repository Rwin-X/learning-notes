---
tags: [bash-course, cheatsheet, reference]
---

# Bash Cheat Sheet

> Everything above, compressed. Use search (press/) to jump straight to any command.

## Essential

| Command | Description |
|---|---|
| `pwd` | print working directory |
| `ls -la` | list all, long format |
| `cd path` | change directory |
| `man cmd` | show manual page |
| `clear` | clear the terminal |
| `history` | show command history |

## File Operations

| Command | Description |
|---|---|
| `mkdir -p a/b` | create nested dirs |
| `touch file` | create/update file |
| `cp -r src dst` | copy recursively |
| `mv old new` | move / rename |
| `rm -rf dir` | delete recursively (careful) |
| `cat file` | print whole file |
| `less file` | scroll through file |
| `head -n5 file` | first 5 lines |
| `tail -f file` | follow file live |

## Variables

| Command | Description |
|---|---|
| `x=5` | assign (no spaces) |
| `echo $x` | read variable |
| `export X=5` | make available to children |
| `$(cmd)` | command substitution |
| `${var:-def}` | default if unset |
| `${#var}` | string length |

## Operators

| Command | Description |
|---|---|
| `&&` | run next if success |
| `\|\|` | run next if failure |
| `;` | run next regardless |
| `$((a+b))` | integer arithmetic |
| `$?` | last exit code |

## Conditions

| Command | Description |
|---|---|
| `[ -f file ]` | file exists |
| `[ -d dir ]` | directory exists |
| `[ "$a" = "$b" ]` | string equal |
| `[ "$a" -eq "$b" ]` | numeric equal |
| `[[ $s =~ regex ]]` | regex match |

## Loops

| Command | Description |
|---|---|
| `for x in list; do` | loop over items |
| `while [ cond ]; do` | loop while true |
| `until [ cond ]; do` | loop until true |
| `break / continue` | control flow inside loops |

## Functions

| Command | Description |
|---|---|
| `f() { cmds; }` | define a function |
| `f arg1 arg2` | call with arguments |
| `local x=1` | scope var to function |
| `return N` | set function exit code |

## Arguments

| Command | Description |
|---|---|
| `$1 $2` | positional arguments |
| `$@` | all arguments, separate words |
| `$#` | argument count |
| `shift` | drop first argument |

## Pipes & Redirection

| Command | Description |
|---|---|
| `a \| b` | pipe output of a into b |
| `cmd > file` | overwrite file |
| `cmd >> file` | append to file |
| `cmd 2>&1` | merge stderr into stdout |
| `cmd < file` | read file as input |

## Text Processing

| Command | Description |
|---|---|
| `grep -in pat file` | search, ignore case, show line # |
| `sed 's/a/b/g' file` | find & replace |
| `awk '{print $1}'` | print column 1 |
| `sort -rn` | sort numeric, reverse |
| `uniq -c` | count duplicate lines |
| `cut -d: -f1` | extract field by delimiter |
| `wc -l` | count lines |
| `xargs cmd` | run cmd per input line |

## Permissions

| Command | Description |
|---|---|
| `chmod +x file` | make executable |
| `chmod 644 file` | rw-r--r-- |
| `chmod 755 file` | rwxr-xr-x |
| `chown user:grp file` | change owner |

## Processes

| Command | Description |
|---|---|
| `ps aux` | list all processes |
| `top` | live process monitor |
| `kill PID` | terminate gracefully |
| `kill -9 PID` | force terminate |
| `cmd &` | run in background |
| `jobs` | list background jobs |

## Networking

| Command | Description |
|---|---|
| `curl -sI url` | fetch headers only |
| `wget -O file url` | download to file |
| `ssh user@host` | remote shell |
| `ping -c4 host` | test connectivity |
| `ss -tulnp` | list listening ports |

## Debugging

| Command | Description |
|---|---|
| `bash -n script.sh` | check syntax only |
| `bash -x script.sh` | trace execution |
| `set -euo pipefail` | strict mode |
| `trap 'cmd' EXIT` | run cmd on exit |
