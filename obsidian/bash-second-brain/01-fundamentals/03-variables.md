
---
tags: [fundamentals, bash]
aliases: [Bash variables]
---

# Variables

## Declaring and Using

```bash
name="Rwin"        # NO spaces around =
echo "$name"        # use $ to READ a variable
echo $name           # works too, but unquoted is risky (see below)
```

**Critical rule:** `name = "Rwin"` (with spaces) is a syntax error in
Bash — the shell interprets `name` as a command and tries to pass `=`
and `"Rwin"` as arguments to it.

## Variable Scope

- Variables are **local to the shell** by default.
- `export name` makes it available to child processes (subshells,
  scripts you call from this one).

```bash
export API_KEY="xyz"   # child processes can now see $API_KEY
```

## Command Substitution — capturing output into a variable

This is one of the most-used patterns in real scripts:

```bash
current_dir=$(pwd)
echo "You are in: $current_dir"

# Older syntax (still common in legacy scripts, avoid in new code):
current_dir=`pwd`
```

## Special / Built-in Variables

| Variable | Meaning |
|---|---|
| `$0` | Name of the script itself |
| `$1`, `$2`, ... | Positional arguments passed to script/function |
| `$#` | Number of arguments passed |
| `$@` | All arguments, as separate words |
| `$?` | Exit code of the last command |
| `$$` | PID of the current shell |
| `$RANDOM` | A random integer |

Full detail on `$1`, `$@`, `$#` in
[[04-functions-and-scripts/02-arguments-and-exit-codes|Arguments & Exit Codes]].

## Read-only and Unsetting

```bash
readonly PI=3.14159   # cannot be changed after this
unset name             # deletes the variable
```

## Environment Variables vs. Shell Variables

- **Shell variable**: exists only in this shell (`name="x"`)
- **Environment variable**: exported, inherited by child processes
  (`export name="x"`, or built-ins like `$HOME`, `$PATH`, `$USER`)

```bash
echo $HOME    # environment variable, set by the OS/login process
echo $PATH    # colon-separated list of dirs the shell searches for commands
```

---

## Links
- Previous: [[02-shebang-and-execution]]
- Next: [[04-quoting-and-expansion]]
- Related: [[03-data-structures/01-arrays|Arrays]] (variables that hold lists), [[04-functions-and-scripts/02-arguments-and-exit-codes|Arguments & Exit Codes]]
- Hub: [[00-MOC]]
