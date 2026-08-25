---
tags: [control-flow, bash]
aliases: [if statement, test command]
---

# Conditionals

## Basic `if` Structure

```bash
if [ "$age" -ge 18 ]; then
    echo "Adult"
elif [ "$age" -ge 13 ]; then
    echo "Teenager"
else
    echo "Child"
fi
```

Notice: **spaces are mandatory** inside `[ ]` — `[$age -ge 18]` is a
syntax error; it must be `[ "$age" -ge 18 ]`.

## `[ ]` vs `[[ ]]`

| | `[ ]` (test command) | `[[ ]]` (Bash keyword) |
|---|---|---|
| Portability | POSIX, works in `sh` too | Bash/Zsh/Ksh only |
| Word splitting | Happens — must quote variables | Doesn't happen — safer with unquoted vars |
| Pattern matching | No | Yes (`==` supports globs) |
| `&&` / `\|\|` inside | Must escape / use `-a`/`-o` | Works naturally |

**Recommendation for scripts that don't need POSIX `sh` portability:
use `[[ ]]`.**

```bash
if [[ $filename == *.txt ]]; then
    echo "It's a text file"
fi
```

## Comparison Operators

**Numeric** (used with `[ ]` or `[[ ]]`):
| Operator | Meaning |
|---|---|
| `-eq` | equal |
| `-ne` | not equal |
| `-gt` | greater than |
| `-lt` | less than |
| `-ge` | greater or equal |
| `-le` | less or equal |

**String:**
| Operator | Meaning |
|---|---|
| `==` or `=` | equal |
| `!=` | not equal |
| `-z` | string is empty |
| `-n` | string is not empty |

```bash
if [[ -z "$name" ]]; then
    echo "Name is empty"
fi
```

⚠️ Common trap: `if [ "$x" = 5 ]` uses **string** comparison; for
numbers use `-eq`. `"05" -eq 5` is true, but `"05" = 5` is false.

## File test conditionals

Covered fully in [[05-file-and-system/01-file-tests|File Tests]], but
the basics:
```bash
if [[ -f "$file" ]]; then echo "Regular file exists"; fi
if [[ -d "$dir" ]]; then echo "Directory exists"; fi
```

## Logical Operators

```bash
if [[ "$age" -ge 18 && "$has_id" == "yes" ]]; then
    echo "Can enter"
fi

if [[ "$role" == "admin" || "$role" == "root" ]]; then
    echo "Privileged"
fi
```

## Exit-code-based conditionals (no brackets at all)

Any command's exit code can drive an `if`:
```bash
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "Internet is up"
else
    echo "No connectivity"
fi
```
This is extremely common in real automation/recon scripts.

## Short-circuit shorthand

```bash
[[ -f "$file" ]] && echo "exists"          # runs echo only if true
[[ -f "$file" ]] || echo "missing"         # runs echo only if false
mkdir -p "$dir" && cd "$dir"                # chain: only cd if mkdir succeeded
```

---

## Links
- Previous: [[01-input-output]]
- Next: [[03-loops]]
- Related: [[05-file-and-system/01-file-tests|File Tests]], [[04-case-statements]]
- Hub: [[00-MOC]]
