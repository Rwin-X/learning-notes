---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# case

> case matches a value against a list of patterns, similar to switch statements in other languages, and is often cleaner than long if/elif chains.

## Syntax
```bash
case $var in
  pattern1) commands ;;
  pattern2) commands ;;
  *) default ;;
esac
```

## Example
```bash
$ read -p "y/n: " ans
$ case $ans in
  y|Y) echo "confirmed" ;;
  n|N) echo "cancelled" ;;
  *) echo "invalid" ;;
esac
```

## Expected output
```
confirmed
```

## ⚠️ Common mistake
Forgetting the double semicolon ;; at the end of each pattern block, which causes the next pattern to be evaluated unexpectedly.

## 💡 Practical use
Ideal for CLI argument parsing, menu-driven scripts, and handling multiple known input formats cleanly.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
