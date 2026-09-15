---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Quoting

> Double quotes allow variable expansion inside them; single quotes treat everything literally, including $ signs. Unquoted variables can break on spaces.

## Syntax
```bash
"$var"   vs   '$var'   vs   $var
```

## Example
```bash
$ name="Rwin Test"
$ echo "$name"
$ echo $name
```

## Expected output
```
Rwin Test
Rwin Test
```

## ⚠️ Common mistake
Leaving variables unquoted when they might contain spaces or be empty — this causes word-splitting bugs that are hard to trace, e.g. if [ $var = "x" ] failing when $var is empty.

## 💡 Practical use
The rule of thumb in professional scripts: always double-quote variable expansions unless you specifically need word-splitting.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
