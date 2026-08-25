
---
tags: [practical, bash]
aliases: [best practices, bash style guide]
---

# Good Practices

A consolidated checklist — pulls together the "don't do this" lessons
scattered across earlier notes into one reference.

## Always Do

- [ ] Start scripts with `#!/usr/bin/env bash` — see
      [[01-fundamentals/02-shebang-and-execution|Shebang & Execution]]
- [ ] Use `set -euo pipefail` unless you have a specific reason not to
      — see [[04-functions-and-scripts/03-script-structure|Script Structure]]
- [ ] Quote every variable expansion: `"$var"` not `$var` — see
      [[01-fundamentals/04-quoting-and-expansion|Quoting & Expansion]]
- [ ] Use `[[ ]]` over `[ ]` for conditionals in Bash-specific scripts
      — see [[02-io-and-flow/02-conditionals|Conditionals]]
- [ ] Use `local` for variables inside functions — see
      [[04-functions-and-scripts/01-functions|Functions]]
- [ ] Check exit codes of critical commands (`&&`, `||`, or explicit
      `if`) rather than assuming success
- [ ] Run `shellcheck` before considering a script "done" — see
      [[03-debugging|Debugging]]
- [ ] Use `mkdir -p` instead of checking-then-creating a directory
- [ ] Redirect error messages to stderr: `echo "Error" >&2`

## Avoid

- ❌ Parsing `ls` output for scripting logic — use globs or `find`
  instead; `ls` output format isn't guaranteed and breaks on filenames
  with spaces/newlines.
- ❌ Backtick command substitution `` `cmd` `` — use `$(cmd)` instead;
  it nests cleanly and is easier to read.
- ❌ Using `eval` unless absolutely necessary — it's a common source of
  injection vulnerabilities if any part of the evaluated string comes
  from user input.
- ❌ Comparing numbers with `=`/`==` — those are string comparisons;
  use `-eq`, `-lt`, etc. or `(( ))`.
- ❌ Silently swallowing all errors with `2>/dev/null` everywhere — you
  lose the ability to debug when something actually breaks.
- ❌ Hardcoding paths/values that should be variables or arguments.

## Naming Conventions

```bash
# Constants: uppercase, readonly
readonly MAX_RETRIES=5

# Regular variables: lowercase with underscores
user_name="rwin"

# Functions: lowercase with underscores, verb-first
check_disk_space() { ... }
```

## Idempotency — a security/automation-relevant habit

Write scripts so re-running them produces the same end state, not
duplicated side effects:

```bash
# Not idempotent — grows the file every run:
echo "export PATH=$PATH:/opt/tool" >> ~/.bashrc

# Idempotent — checks first:
grep -qxF 'export PATH=$PATH:/opt/tool' ~/.bashrc || \
    echo 'export PATH=$PATH:/opt/tool' >> ~/.bashrc
```

## A Minimal "Production-Ready" Template

Combines everything above — this is the pattern to default to once
you're comfortable with the fundamentals:

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"

usage() {
    echo "Usage: $SCRIPT_NAME <arg>" >&2
    exit 1
}

main() {
    [[ $# -lt 1 ]] && usage
    local input="$1"
    echo "Processing: $input"
}

main "$@"
```

---

## Links
- Previous: [[03-debugging]]
- Related: everything — this note is the synthesis point of the vault
- Hub: [[00-MOC]]
