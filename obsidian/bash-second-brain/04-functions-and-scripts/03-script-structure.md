
---
tags: [functions, bash]
aliases: [script layout, script template]
---

# Script Structure

## Anatomy of a Well-Organized Script

```bash
#!/usr/bin/env bash
#
# script_name.sh — one-line description of what this does
#
# Usage: ./script_name.sh [options] <required_arg>

set -euo pipefail   # strict-mode safety net — see below

# ---- Constants / Configuration ----
readonly LOG_FILE="/var/log/myscript.log"
readonly MAX_RETRIES=3

# ---- Functions ----
log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

usage() {
    echo "Usage: $0 [-v] <input_file>"
    exit 1
}

main() {
    [[ $# -eq 0 ]] && usage
    log "Starting script with input: $1"
    # ... actual logic here ...
}

# ---- Entry Point ----
main "$@"
```

Putting logic inside a `main()` function and calling `main "$@"` at the
bottom is a common convention — it keeps top-level scope clean and
makes the script easier to read top-down.

## `set` Options — "strict mode"

```bash
set -e            # exit immediately if any command fails (non-zero exit)
set -u            # error on use of an undefined variable
set -o pipefail   # a pipeline fails if ANY command in it fails, not just the last
set -x            # print each command before executing it (debugging)

set -euo pipefail   # the three combined — very common at the top of serious scripts
```

See [[06-practical/03-debugging|Debugging]] for more on `set -x` and
troubleshooting.

⚠️ Caveat: `set -e` doesn't catch failures inside `if` conditions,
`&&`/`||` chains, or command substitutions in some contexts — it
reduces bugs but isn't a complete safety net. Always test error paths.

## Comment Conventions

```bash
# Single-line comment

: '
This is a common trick for a
multi-line comment block in Bash —
: is a no-op command, and the string is just an unused argument.
'
```

## Where This Fits

- [[01-functions|Functions]] → the reusable logic blocks inside `main`
- [[02-arguments-and-exit-codes|Arguments & Exit Codes]] → how `main "$@"` gets its input
- [[06-practical/04-good-practices|Good Practices]] → broader style conventions beyond structure

---

## Links
- Previous: [[02-arguments-and-exit-codes]]
- Next: [[05-file-and-system/01-file-tests]]
- Related: [[06-practical/03-debugging|Debugging]], [[06-practical/04-good-practices|Good Practices]]
- Hub: [[00-MOC]]
