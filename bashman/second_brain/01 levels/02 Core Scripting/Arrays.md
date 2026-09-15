---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Arrays

> Bash arrays store multiple values in a single variable, indexed starting at 0, accessed and looped over with special syntax.

## Syntax
```bash
arr=(item1 item2 item3)
echo ${arr[0]}
echo ${arr[@]}
```

## Example
```bash
$ servers=(web1 web2 db1)
$ echo "${servers[1]}"
$ echo "${servers[@]}"
```

## Expected output
```
web2
web1 web2 db1
```

## ⚠️ Common mistake
Forgetting the curly braces and @ index — $servers only gives the first element, not the whole array.

## 💡 Practical use
Used to hold lists of servers, files, or usernames that a script needs to loop over and process.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
