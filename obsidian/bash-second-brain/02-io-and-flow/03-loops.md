
---
tags: [control-flow, bash]
aliases: [for loop, while loop, until loop]
---

# Loops

## `for` Loop

```bash
# Iterate over a list of literal words
for color in red green blue; do
    echo "Color: $color"
done

# Iterate over files matching a glob
for file in *.txt; do
    echo "Found: $file"
done

# C-style for loop
for ((i = 0; i < 5; i++)); do
    echo "i = $i"
done

# Range using brace expansion
for i in {1..10}; do
    echo "$i"
done

# Iterate over an array
fruits=("apple" "banana" "cherry")
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done
```
Array syntax detail is in [[03-data-structures/01-arrays|Arrays]].

## `while` Loop

Runs **while** the condition is true.

```bash
count=1
while [[ $count -le 5 ]]; do
    echo "Count: $count"
    ((count++))
done
```

Classic pattern — read a file line by line:
```bash
while read -r line; do
    echo "Processing: $line"
done < "input.txt"
```

Infinite loop with manual break (common in monitoring scripts):
```bash
while true; do
    echo "Checking..."
    sleep 5
done
```

## `until` Loop

Runs **until** the condition becomes true — i.e. opposite of `while`.

```bash
count=1
until [[ $count -gt 5 ]]; do
    echo "Count: $count"
    ((count++))
done
```
`until` is functionally rare in practice — most people just negate the
`while` condition — but you'll see it in older scripts.

## Loop Control: `break` and `continue`

```bash
for i in {1..10}; do
    if [[ $i -eq 5 ]]; then
        break        # exit the loop entirely
    fi
    echo "$i"
done

for i in {1..5}; do
    if [[ $((i % 2)) -eq 0 ]]; then
        continue     # skip to next iteration
    fi
    echo "$i"        # only prints odd numbers
done
```

## Reading Command Output Line-by-Line (a critical real-world pattern)

```bash
ls -1 *.log | while read -r file; do
    echo "Archiving: $file"
done
```
⚠️ Caveat: variables set **inside** a `while` loop fed by a pipe live in
a subshell and won't persist after the loop. If that matters, use
process substitution instead:
```bash
while read -r file; do
    count=$((count + 1))
done < <(ls -1 *.log)
echo "Total: $count"   # this WORKS because no pipe/subshell was used
```

---

## Links
- Previous: [[02-conditionals]]
- Next: [[04-case-statements]]
- Related: [[03-data-structures/01-arrays|Arrays]], [[06-practical/01-pipes-and-redirection|Pipes & Redirection]]
- Hub: [[00-MOC]]
