---
tags: [functions, bash]
aliases: [Bash functions]
---

# Functions

## Defining and Calling

```bash
greet() {
    echo "Hello, $1!"
}

greet "Rwin"      # → Hello, Rwin!
```

Alternative (older, `function` keyword) syntax — functionally
equivalent, but `name()` is more portable:
```bash
function greet {
    echo "Hello, $1!"
}
```

## Functions Don't "Return" Values Like Other Languages

This is the #1 conceptual trap. `return` in Bash only sets the
**exit code** (0–255) — it cannot return a string or a computed value
the way `return` does in Python/JS.

```bash
is_even() {
    if (( $1 % 2 == 0 )); then
        return 0    # success = "true"
    else
        return 1    # failure = "false"
    fi
}

if is_even 4; then
    echo "Even"
fi
```

**To get a "return value" out, use `echo` + command substitution:**

```bash
get_full_name() {
    echo "$1 $2"
}

full_name=$(get_full_name "Ada" "Lovelace")
echo "$full_name"    # Ada Lovelace
```

## Parameters Inside a Function

Functions use the same positional-parameter convention as scripts:

```bash
show_args() {
    echo "First: $1"
    echo "All: $@"
    echo "Count: $#"
}

show_args a b c
```
Full detail on `$1`/`$@`/`$#` in
[[02-arguments-and-exit-codes|Arguments & Exit Codes]] — it applies
identically whether at script level or function level.

## Local Variables

By default, variables set inside a function are **global** unless
declared `local` — a frequent source of bugs.

```bash
counter=10

modify() {
    local counter=99   # this ONLY affects the local scope
    echo "Inside: $counter"
}

modify
echo "Outside: $counter"    # still 10 — unaffected
```
**Always use `local` for variables inside functions unless you
deliberately want to modify a global.**

## Practical Example: reusable validation function

```bash
require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Error: this script must be run as root" >&2
        exit 1
    fi
}

require_root
echo "Continuing as root..."
```

---

## Links
- Previous: [[03-data-structures/02-strings]]
- Next: [[02-arguments-and-exit-codes]]
- Related: [[03-script-structure]]
- Hub: [[00-MOC]]
