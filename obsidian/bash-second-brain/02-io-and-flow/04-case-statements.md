
---
tags: [control-flow, bash]
aliases: [case, switch statement]
---

# Case Statements

`case` is Bash's answer to `switch` in other languages — cleaner than a
long `if/elif` chain when matching one variable against several
patterns.

## Basic Syntax

```bash
read -p "Enter a fruit: " fruit

case "$fruit" in
    apple)
        echo "It's an apple"
        ;;
    banana | plantain)
        echo "It's a banana-family fruit"
        ;;
    *)
        echo "Unknown fruit"
        ;;
esac
```

- `;;` ends each pattern's block (like `break` in other languages).
- `|` means OR between patterns.
- `*)` is the catch-all/default case, conventionally last.
- Patterns support globbing, e.g. `*.txt)`, `[0-9])`.

## Real-World Example: Argument Parsing

```bash
case "$1" in
    -h|--help)
        echo "Usage: script.sh [options]"
        ;;
    -v|--verbose)
        set -x
        ;;
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    *)
        echo "Unknown option: $1"
        exit 1
        ;;
esac
```
This exact pattern is extremely common at the top of CLI-style scripts
— see [[04-functions-and-scripts/02-arguments-and-exit-codes|Arguments & Exit Codes]].

## When to Use `case` Over `if/elif`

Use `case` when you're matching **one variable** against **multiple
discrete values or patterns**. Use `if/elif` when conditions involve
different variables or complex logical combinations (`&&`, `||` across
multiple checks).

---

## Links
- Previous: [[03-loops]]
- Next: [[03-data-structures/01-arrays]]
- Related: [[02-conditionals]], [[04-functions-and-scripts/02-arguments-and-exit-codes|Arguments & Exit Codes]]
- Hub: [[00-MOC]]
