---
tags: [control-flow, bash]
aliases: [echo, printf, read]
---

# Input & Output

## Output: `echo` vs `printf`

```bash
echo "Hello, World"          # simple, adds trailing newline automatically
echo -n "No newline"         # suppress the newline
echo -e "Tab:\tNewline:\n"   # -e enables backslash escape interpretation

printf "Name: %s, Age: %d\n" "Rwin" 25   # C-style formatting, more predictable
```

`printf` is generally preferred in serious scripts because `echo`'s
behavior with flags/escapes varies slightly across shells — `printf`
is consistent.

## Input: `read`

```bash
read -p "Enter your name: " name
echo "Hello, $name"

read -s -p "Password: " pass   # -s = silent (no echo to screen)
echo
```

Reading multiple values at once:
```bash
read -p "First and last name: " first last
echo "First: $first, Last: $last"
```

Reading a file line by line:
```bash
while read -r line; do
    echo "Line: $line"
done < "input.txt"
```
`-r` prevents backslashes in the input from being interpreted as
escape characters — almost always what you want.

## The Three Standard Streams

| Stream | File descriptor | Default destination |
|---|---|---|
| stdin | 0 | keyboard / piped input |
| stdout | 1 | terminal screen |
| stderr | 2 | terminal screen (separate from stdout!) |

```bash
command > output.txt        # redirect stdout to a file (overwrite)
command 2> errors.txt        # redirect stderr only
command > all.txt 2>&1       # redirect BOTH stdout and stderr to same file
command &> all.txt           # shorthand for the line above
```

Full redirection and piping detail lives in
[[06-practical/01-pipes-and-redirection|Pipes & Redirection]] — this
note is just the fundamentals.

---

## Links
- Previous: [[01-fundamentals/04-quoting-and-expansion]]
- Next: [[02-conditionals]]
- Related: [[06-practical/01-pipes-and-redirection|Pipes & Redirection]]
- Hub: [[00-MOC]]
