---
tags: [data-structures, bash]
aliases: [Bash arrays, indexed arrays, associative arrays]
---

# Arrays

## Indexed Arrays (the default kind)

```bash
fruits=("apple" "banana" "cherry")

echo "${fruits[0]}"        # apple  (0-indexed)
echo "${fruits[@]}"        # apple banana cherry  (all elements)
echo "${#fruits[@]}"       # 3      (length/count of elements)

fruits+=("date")            # append an element
fruits[1]="blueberry"       # overwrite index 1

unset 'fruits[0]'           # remove element at index 0 (note the quotes)
```

## Iterating

```bash
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done

# With index:
for i in "${!fruits[@]}"; do
    echo "Index $i: ${fruits[$i]}"
done
```

`"${!fruits[@]}"` gives you the **indices**, not the values — useful
when you need position info.

## `@` vs `*` — the quoting trap

```bash
arr=("one two" "three")

for x in "${arr[@]}"; do echo "[$x]"; done
# → [one two]
#   [three]      -- preserves each element as-is (usually what you want)

for x in "${arr[*]}"; do echo "[$x]"; done
# → [one two three]   -- flattens into ONE string (usually not what you want)
```
**Rule of thumb: use `"${arr[@]}"` almost always.**

## Associative Arrays (key-value / "dictionaries")

Require explicit declaration — must be declared with `-A`:

```bash
declare -A user
user[name]="Rwin"
user[role]="student"

echo "${user[name]}"        # Rwin

for key in "${!user[@]}"; do
    echo "$key => ${user[$key]}"
done
```

## Practical Use Case: deduplicating a list

```bash
declare -A seen
for item in "${input_list[@]}"; do
    if [[ -z "${seen[$item]}" ]]; then
        seen[$item]=1
        echo "$item"
    fi
done
```

---

## Links
- Previous: [[02-io-and-flow/04-case-statements]]
- Next: [[02-strings]]
- Related: [[02-io-and-flow/03-loops|Loops]]
- Hub: [[00-MOC]]
