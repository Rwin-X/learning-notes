
---
tags: [functions, bash]
aliases: [positional parameters, exit status, dollar question mark]
---

# Arguments & Exit Codes

## Positional Parameters (Script Arguments)

```bash
#!/bin/bash
# Called as: ./script.sh alpha beta gamma

echo "Script name: $0"
echo "First arg:   $1"
echo "Second arg:  $2"
echo "All args:    $@"
echo "Arg count:   $#"
```

| Variable | Meaning |
|---|---|
| `$0` | Script's own name/path |
| `$1`...`$9` | Positional arguments (use `${10}` for 10th onward) |
| `$@` | All arguments as **separate** words — almost always what you want |
| `$*` | All arguments as **one** merged string — rarely what you want |
| `$#` | Total count of arguments |

Same `@` vs `*` quoting trap as with arrays — see
[[03-data-structures/01-arrays|Arrays]].

## `shift` — consuming arguments one at a time

```bash
while [[ $# -gt 0 ]]; do
    echo "Processing: $1"
    shift    # drops $1, moves $2 into $1, etc.
done
```
This is the backbone of manual CLI-flag parsing:

```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose) verbose=true; shift ;;
        -o|--output) output_file="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done
```
See [[02-io-and-flow/04-case-statements|Case Statements]] for the
`case` mechanics used here.

## Exit Codes

Every command and script returns a numeric exit status when it
finishes:

- `0` = success
- `1–255` = failure (the specific number's meaning is defined by
  whoever wrote the program — there's no universal standard beyond 0)

```bash
grep "pattern" file.txt
echo $?     # 0 if found, 1 if not found, 2 if file doesn't exist
```

### Setting your own script's exit code

```bash
#!/bin/bash
if [[ ! -f "$1" ]]; then
    echo "Error: file not found" >&2
    exit 1
fi
echo "File exists, proceeding"
exit 0
```

### Why this matters for chaining scripts

Other scripts, `if` statements, and `&&`/`||` all rely on exit codes.
A script that always exits `0` (even on failure) will silently break
any automation depending on it — a real and common bug.

```bash
./backup.sh && echo "Backup succeeded" || echo "Backup FAILED"
```

---

## Links
- Previous: [[01-functions]]
- Next: [[03-script-structure]]
- Related: [[02-io-and-flow/02-conditionals|Conditionals]], [[02-io-and-flow/04-case-statements|Case Statements]]
- Hub: [[00-MOC]]
