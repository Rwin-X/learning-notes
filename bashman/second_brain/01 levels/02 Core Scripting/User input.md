---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# User input

> The read builtin pauses a script and waits for the user to type something, storing it in a variable.

## Syntax
```bash
read -p "prompt text" variable_name
```

## Example
```bash
$ read -p "Enter your name: " name
Enter your name: Rwin
$ echo "Hi, $name"
```

## Expected output
```
Hi, Rwin
```

## ⚠️ Common mistake
Forgetting -p and being confused when the script just silently waits with no visible prompt on screen.

## 💡 Practical use
Used in interactive setup scripts, confirmation prompts ("Are you sure? [y/N]"), and CLI tools like the To-Do List project.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
