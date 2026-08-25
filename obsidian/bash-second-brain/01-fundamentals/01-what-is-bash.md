---
tags: [fundamentals, bash]
aliases: [Bash intro, Introduction to Bash]
---

# What is Bash?

**Bash** (Bourne Again SHell) is a command interpreter — a program that
reads text you type (or a text file) and translates it into actions the
operating system performs: running programs, moving data between them,
managing files.

## Shell vs. Terminal vs. Bash — don't confuse these

| Term | What it actually is |
|---|---|
| **Terminal** | The window/app that displays text input and output |
| **Shell** | The program interpreting your commands (bash, zsh, sh, fish...) |
| **Bash** | One specific shell — the most common default on Linux |

## Two ways to use Bash

1. **Interactive mode** — you type commands one at a time at a prompt.
2. **Script mode** — commands are written in a `.sh` file and executed
   as a batch. This is what "Bash scripting" means.

```bash
# Interactive: typed directly at the prompt
$ echo "hello"
hello

# Script mode: saved in a file, e.g. hello.sh
#!/bin/bash
echo "hello"
```

## Why Bash matters for you specifically

For cybersecurity and automation work, Bash is the connective tissue
between tools — piping `nmap` output into `grep`, automating recon
loops, parsing logs. It's less a "programming language" in the C/Python
sense and more an **orchestration layer** over other programs.

## Core Mental Model (repeat this to yourself)

> Bash scripts are mostly: run a program → capture its text output →
> make a decision or transform the text → feed it to the next program.

Everything you learn next (variables, loops, conditionals) exists to
support that loop.

---

## Links
- Next: [[02-shebang-and-execution]]
- Related: [[06-practical/02-common-utilities|Common Utilities]]
- Hub: [[00-MOC]]
