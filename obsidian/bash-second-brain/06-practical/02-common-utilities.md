
---
tags: [practical, bash]
aliases: [grep, sed, awk, find, cut]
---

# Common Utilities

These aren't "Bash syntax" — they're external programs almost every
Bash script relies on. Learning Bash without these is like learning
grammar without vocabulary.

## `grep` — search text by pattern

```bash
grep "error" log.txt              # lines containing "error"
grep -i "error" log.txt            # case-insensitive
grep -r "TODO" ./src                # recursive through a directory
grep -v "debug" log.txt             # invert match — lines NOT containing "debug"
grep -c "error" log.txt             # count matching lines
grep -E "err(or)?" log.txt          # extended regex
```

## `find` — locate files by attributes

```bash
find . -name "*.txt"                     # by name pattern
find . -type f -mtime -7                  # files modified in the last 7 days
find . -type d -name "node_modules"        # directories by name
find . -size +100M                          # files larger than 100MB
find . -name "*.sh" -exec chmod +x {} \;    # find AND act on each result
```

## `sed` — stream editor (find & replace, mainly)

```bash
sed 's/foo/bar/' file.txt           # replace first "foo" per line with "bar"
sed 's/foo/bar/g' file.txt          # replace ALL occurrences (g = global)
sed -i 's/foo/bar/g' file.txt        # -i = edit the file IN PLACE
sed -n '5,10p' file.txt               # print only lines 5 through 10
```

## `awk` — column-based text processing

```bash
awk '{print $1}' file.txt              # print first column (whitespace-separated)
awk -F: '{print $1}' /etc/passwd        # -F sets a custom field separator
awk '{sum += $2} END {print sum}' data.txt   # sum column 2 across all lines
```

## `cut` — extract columns/fields simply

```bash
cut -d: -f1 /etc/passwd       # -d sets delimiter, -f selects field number
cut -c1-5 file.txt              # extract characters 1 through 5
```

## `sort` and `uniq`

```bash
sort file.txt                    # alphabetical sort
sort -n numbers.txt               # numeric sort
sort -r file.txt                   # reverse order
sort file.txt | uniq                # remove adjacent duplicate lines (must be sorted first)
sort file.txt | uniq -c              # count occurrences of each line
```

## `wc` — word/line/byte counts

```bash
wc -l file.txt      # count lines
wc -w file.txt       # count words
wc -c file.txt        # count bytes
```

## `xargs` — turn stdin into command arguments

```bash
find . -name "*.tmp" | xargs rm         # delete every file `find` lists
echo "file1 file2" | xargs -n1 echo      # run echo once per argument
```

## `tr` — translate/delete characters

```bash
echo "hello" | tr 'a-z' 'A-Z'      # HELLO
echo "hello world" | tr -d ' '       # helloworld (delete spaces)
```

## Where These Fit Together

A realistic one-liner combining several of these:
```bash
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
# → top 10 most frequent IP addresses in a log file
```

---

## Links
- Previous: [[01-pipes-and-redirection]]
- Next: [[03-debugging]]
- Related: [[03-data-structures/02-strings|Strings]] (Bash-native alternative to some of these for simple cases)
- Hub: [[00-MOC]]
