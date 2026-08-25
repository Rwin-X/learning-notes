
---
tags: [fundamentals, bash]
aliases: [Quoting, Word splitting, Globbing]
---

# Quoting & Expansion

This is the single biggest source of bugs for Bash beginners. Understand
this note thoroughly.

## The Three Quote Types

| Quote | Behavior |
|---|---|
| `'single'` | Literal. NOTHING is expanded inside — not `$vars`, not `$(commands)`. |
| `"double"` | Variables and command substitution ARE expanded. Spaces preserved. |
| No quotes | Variables expanded, THEN the result is **word-split** and **glob-expanded**. Dangerous. |

```bash
name="Rwin"

echo 'Hello $name'    # → Hello $name        (literal)
echo "Hello $name"    # → Hello Rwin         (expanded)
echo Hello $name      # → Hello Rwin         (works here, but fragile)
```

## Why Unquoted Variables Are Dangerous

```bash
file="my document.txt"

rm $file      # BREAKS: expands to `rm my document.txt`
              # → tries to delete TWO files: "my" and "document.txt"

rm "$file"    # CORRECT: expands to `rm "my document.txt"`
              # → deletes ONE file, the intended one
```

**Rule of thumb: always quote variable expansions — `"$var"` — unless
you have a specific reason not to (rare).**

## Word Splitting

When unquoted, Bash splits a variable's value on whitespace (defined by
`$IFS`, the Internal Field Separator) and treats each piece as a
separate argument. This is what caused the `rm $file` bug above.

## Globbing (Pathname Expansion)

Unquoted `*`, `?`, `[...]` are expanded by the shell into matching
filenames **before** the command even runs:

```bash
ls *.txt       # shell expands *.txt to every matching filename
echo "*.txt"   # prints the literal string *.txt — no expansion, it's quoted
```

## Command Substitution

```bash
today=$(date +%F)          # preferred modern syntax
today=`date +%F`           # legacy backtick syntax — avoid, hard to nest
```

## Arithmetic Expansion

```bash
result=$((5 + 3))
echo "$result"      # 8

count=$((count + 1))   # increment pattern
```

## Brace Expansion

```bash
echo file{1,2,3}.txt    # → file1.txt file2.txt file3.txt
echo {a..e}               # → a b c d e
mkdir dir_{1..5}          # creates dir_1 through dir_5
```

## Escaping

```bash
echo "Cost: \$5"      # backslash escapes the $ → Cost: $5
```

---

## Links
- Previous: [[03-variables]]
- Next: [[02-io-and-flow/01-input-output]]
- Related: [[03-data-structures/02-strings|Strings]]
- Hub: [[00-MOC]]
