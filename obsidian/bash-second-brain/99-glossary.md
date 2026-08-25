---
tags: [reference, bash]
aliases: [Bash glossary, terms]
---

# Glossary

Quick-lookup reference for terms used throughout the vault.

| Term | Definition | See also |
|---|---|---|
| **Shell** | Program that interprets and executes commands | [[01-fundamentals/01-what-is-bash]] |
| **Shebang** | `#!` line specifying which interpreter runs a script | [[01-fundamentals/02-shebang-and-execution]] |
| **Subshell** | A child shell process spawned to run a command/script | [[01-fundamentals/02-shebang-and-execution]] |
| **Environment variable** | A variable exported to child processes | [[01-fundamentals/03-variables]] |
| **Command substitution** | Capturing a command's output as a value: `$(cmd)` | [[01-fundamentals/03-variables]] |
| **Word splitting** | Unquoted variable expansion split into separate words on whitespace | [[01-fundamentals/04-quoting-and-expansion]] |
| **Globbing** | Unquoted `*`/`?`/`[]` expanded into matching filenames | [[01-fundamentals/04-quoting-and-expansion]] |
| **Exit code / exit status** | Numeric result (0–255) a command returns on completion; 0 = success | [[04-functions-and-scripts/02-arguments-and-exit-codes]] |
| **Positional parameter** | `$1`, `$2`, etc. — arguments passed to a script or function | [[04-functions-and-scripts/02-arguments-and-exit-codes]] |
| **Pipe** | `\|` — connects one command's stdout to the next command's stdin | [[06-practical/01-pipes-and-redirection]] |
| **Redirection** | Sending stdout/stderr to a file or another stream (`>`, `>>`, `2>&1`) | [[06-practical/01-pipes-and-redirection]] |
| **stdin / stdout / stderr** | The three default I/O streams (fd 0, 1, 2) | [[02-io-and-flow/01-input-output]] |
| **Parameter expansion** | Bash's built-in string manipulation syntax: `${var...}` | [[03-data-structures/02-strings]] |
| **Indexed array** | Ordered list of values accessed by numeric index | [[03-data-structures/01-arrays]] |
| **Associative array** | Key-value store, requires `declare -A` | [[03-data-structures/01-arrays]] |
| **Local variable** | A function-scoped variable, declared with `local` | [[04-functions-and-scripts/01-functions]] |
| **`set -e`** | Shell option: exit immediately on any command failure | [[04-functions-and-scripts/03-script-structure]] |
| **`set -u`** | Shell option: error on use of an undefined variable | [[04-functions-and-scripts/03-script-structure]] |
| **Strict mode** | Common shorthand for `set -euo pipefail` | [[04-functions-and-scripts/03-script-structure]] |
| **Process substitution** | `<(cmd)` — presents a command's output as a temp file path | [[06-practical/01-pipes-and-redirection]] |
| **Signal** | An OS-level message sent to a process (e.g. SIGTERM, SIGKILL) | [[05-file-and-system/03-process-basics]] |
| **Idempotent** | An operation that produces the same result no matter how many times it runs | [[06-practical/04-good-practices]] |
| **shellcheck** | Static analysis linter for shell scripts | [[06-practical/03-debugging]] |

---

## Links
- Hub: [[00-MOC]]
