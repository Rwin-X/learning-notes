---
tags: [bash-course, concept, level-01]
level: "[[01 Foundation]]"
---

# Shell vs Terminal

> The terminal is the window (the display). The shell is the program running inside it that actually interprets your commands. Bash is one kind of shell.

## Syntax
```bash
terminal (window) → runs → shell (bash, zsh, sh...)
```

## Example
```bash
$ echo $SHELL
```

## Expected output
```
/bin/bash
```

## ⚠️ Common mistake
Saying "open the shell" when you mean "open the terminal app," or vice versa — they're layered, not the same thing.

## 💡 Practical use
When debugging "why doesn't my script work," the first question is always: which shell is actually running it?

## Notes

## Related
- [[01 Foundation]]
- [[Bash Cheat Sheet]]
