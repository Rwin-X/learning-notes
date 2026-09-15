---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# while

> while runs a block repeatedly as long as a condition remains true — useful for polling, reading input line by line, or waiting on a state.

## Syntax
```bash
while [ condition ]; do
  commands
done
```

## Example
```bash
$ count=1
$ while [ "$count" -le 3 ]; do echo "Attempt $count"; count=$((count+1)); done
```

## Expected output
```
Attempt 1
Attempt 2
Attempt 3
```

## ⚠️ Common mistake
Forgetting to update the loop variable inside the loop, creating an infinite loop that never terminates.

## 💡 Practical use
Common pattern: while read -r line; do ... done < file.txt to process a file line by line safely.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
