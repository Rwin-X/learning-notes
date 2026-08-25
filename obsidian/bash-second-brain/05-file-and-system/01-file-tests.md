---
tags: [filesystem, bash]
aliases: [file test operators, -f -d -e]
---

# File Tests

Used inside `[[ ]]` or `[ ]` (see [[02-io-and-flow/02-conditionals|Conditionals]])
to check facts about the filesystem before acting.

## Common Test Operators

| Operator | True if... |
|---|---|
| `-e` | Path exists (any type) |
| `-f` | Regular file exists |
| `-d` | Directory exists |
| `-L` | Symbolic link exists |
| `-r` | File is readable |
| `-w` | File is writable |
| `-x` | File is executable |
| `-s` | File exists and is NOT empty (size > 0) |
| `-nt` | File is newer than another file |
| `-ot` | File is older than another file |

## Practical Examples

```bash
if [[ -f "config.txt" ]]; then
    echo "Config file found"
else
    echo "Config missing — creating default"
    touch config.txt
fi

if [[ -d "/backup" ]]; then
    echo "Backup directory exists"
fi

if [[ ! -x "script.sh" ]]; then
    echo "Script isn't executable — fixing"
    chmod +x script.sh
fi

if [[ -s "log.txt" ]]; then
    echo "Log has content"
else
    echo "Log is empty or missing"
fi
```

## Combining File Tests

```bash
if [[ -f "$file" && -r "$file" ]]; then
    echo "File exists and is readable"
fi
```

## A Common Real Pattern: safe directory creation

```bash
target_dir="output"
if [[ ! -d "$target_dir" ]]; then
    mkdir -p "$target_dir"
fi
# or, more concisely:
mkdir -p "$target_dir"   # -p makes mkdir a no-op if it already exists — no test needed
```

---

## Links
- Previous: [[04-functions-and-scripts/03-script-structure]]
- Next: [[02-permissions]]
- Related: [[02-io-and-flow/02-conditionals|Conditionals]]
- Hub: [[00-MOC]]
