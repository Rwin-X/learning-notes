
---
tags: [data-structures, bash]
aliases: [string manipulation, parameter expansion]
---

# Strings

Bash has no dedicated "string type" — everything is a string unless
treated as a number via `((...))` or `-eq`-style tests. But Bash offers
rich built-in string manipulation via **parameter expansion**, avoiding
the need to call external tools like `sed`/`awk` for simple tasks.

## Length

```bash
str="hello world"
echo "${#str}"          # 11
```

## Substring Extraction

```bash
str="Hello, World!"
echo "${str:7}"          # World!         (from index 7 to end)
echo "${str:7:5}"        # World          (5 chars starting at index 7)
echo "${str: -6}"        # World!         (negative index = from the end; note the space before -6)
```

## Replacing

```bash
str="I like cats. Cats are great."

echo "${str/cats/dogs}"     # I like dogs. Cats are great.   (first match only)
echo "${str//cats/dogs}"    # case-sensitive, replaces ALL matching "cats" (lowercase only here)
```
`/` = replace first occurrence, `//` = replace all occurrences.

## Removing Prefixes/Suffixes (very useful for file paths)

```bash
file="/home/user/document.txt"

echo "${file#*/}"       # home/user/document.txt   (remove shortest match from front)
echo "${file##*/}"      # document.txt              (remove longest match from front → just filename)
echo "${file%.*}"       # /home/user/document       (remove shortest match from end → strip extension)
echo "${file%%.*}"      # /home/user/document       (remove longest match from end)
```
Mnemonic: `#` trims from the **front** (think of it as pushing from the
left), `%` trims from the **back**. Doubling the symbol (`##`, `%%`) is
"greedy" — matches as much as possible.

## Case Conversion (Bash 4+)

```bash
str="Hello World"
echo "${str,,}"    # hello world   (all lowercase)
echo "${str^^}"    # HELLO WORLD   (all uppercase)
```

## Default Values (extremely common in scripts)

```bash
echo "${name:-Guest}"       # use "Guest" if $name is unset or empty (doesn't change $name)
name="${name:=Guest}"        # same, but ALSO assigns Guest to $name if unset
echo "${name:?Error: name required}"   # print error and exit script if $name is unset
```

## Splitting a String into an Array

```bash
csv="apple,banana,cherry"
IFS=',' read -ra fruits <<< "$csv"
echo "${fruits[1]}"    # banana
```
See [[01-arrays|Arrays]] for what `${fruits[1]}` means, and
[[01-fundamentals/04-quoting-and-expansion|Quoting & Expansion]] for `IFS`.

## Checking Substring Containment

```bash
str="Hello World"
if [[ "$str" == *"World"* ]]; then
    echo "Contains World"
fi
```

---

## Links
- Previous: [[01-arrays]]
- Next: [[04-functions-and-scripts/01-functions]]
- Related: [[01-fundamentals/04-quoting-and-expansion|Quoting & Expansion]]
- Hub: [[00-MOC]]
