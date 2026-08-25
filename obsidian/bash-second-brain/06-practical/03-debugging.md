
---
tags: [practical, bash]
aliases: [bash debugging, set -x, shellcheck]
---

# Debugging

## `set -x` — Trace Execution

Prints every command (with expanded variables) before running it:

```bash
#!/bin/bash
set -x
name="Rwin"
echo "Hello, $name"
set +x    # turn tracing back off
```
Output looks like:
```
+ name=Rwin
+ echo Hello, Rwin
Hello, Rwin
```

You can also enable it for a single run without editing the file:
```bash
bash -x script.sh
```

## `set -v` — Verbose Mode

Prints each line of the script as it's read, **before** expansion
(complements `-x`, which shows it **after** expansion).

## Debugging Checklist for a Broken Script

1. Run with `bash -x script.sh` to see exactly what executed.
2. Check `echo $?` after the failing line to inspect the exit code.
3. Check for unquoted variables — see
   [[01-fundamentals/04-quoting-and-expansion|Quoting & Expansion]].
4. Check for missing spaces inside `[ ]` — see
   [[02-io-and-flow/02-conditionals|Conditionals]].
5. Confirm the shebang and line endings — Windows-edited scripts often
   have `\r\n` line endings that break Bash silently.

```bash
# Detect Windows line endings:
file script.sh    # will report "CRLF line terminators" if affected

# Fix:
sed -i 's/\r$//' script.sh
# or:
dos2unix script.sh
```

## `shellcheck` — Static Analysis (highly recommended)

A linter purpose-built for shell scripts — catches quoting bugs,
unused variables, and common Bash pitfalls before you even run the
script.

```bash
shellcheck script.sh
```
If not installed: `sudo apt install shellcheck` (Debian/Ubuntu) or
equivalent for your distro. This single tool will catch a large
fraction of the bugs covered across
[[01-fundamentals/04-quoting-and-expansion|Quoting & Expansion]] and
[[02-io-and-flow/02-conditionals|Conditionals]].

## Adding Debug Output Manually

```bash
debug() {
    [[ "${DEBUG:-0}" == "1" ]] && echo "[DEBUG] $*" >&2
}

debug "value of x is $x"
```
Run with `DEBUG=1 ./script.sh` to see debug lines; normal runs stay
clean. Sending debug output to stderr (`>&2`) keeps it separate from
the script's real stdout output — relevant to
[[01-pipes-and-redirection|Pipes & Redirection]].

## Testing Small Snippets Interactively

Before committing logic to a script file, test tricky expansions
directly in an interactive shell — much faster feedback loop than
editing → saving → running a whole file each time.

---

## Links
- Previous: [[02-common-utilities]]
- Next: [[04-good-practices]]
- Related: [[01-fundamentals/04-quoting-and-expansion|Quoting & Expansion]], [[04-functions-and-scripts/03-script-structure|Script Structure]]
- Hub: [[00-MOC]]
