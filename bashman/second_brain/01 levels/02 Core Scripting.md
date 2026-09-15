---
tags: [bash-course, level, level-02]
---

# 02 Core Scripting

> This is where Bash stops being "commands you type" and becomes "programs you write" — variables, logic, loops, and functions that make scripts reusable and reliable.

| Field | Value |
|---|---|
| Difficulty | Beginner+ |
| Time | ~6–8 hours |
| Skills gained | variables, control flow, functions, arguments |
| Prerequisites | Level 01 |
| Final challenge | Write a function-based file existence checker |

## Concepts

- [[Bash scripts]] — A Bash script is just a text file full of commands you'd normally type one by one, saved so they can be run together, repeatedly, and automatically.
- [[Shebang]] — The shebang (#!) on the first line of a script tells the operating system which interpreter should run it, so you can execute it directly instead of typing bash first.
- [[Variables]] — Variables store values you can reuse. Bash variables have no type declaration and no spaces around the = sign.
- [[Environment variables]] — Environment variables are variables available to every process launched from your shell, not just the current script. Common ones include PATH, HOME, and USER.
- [[User input]] — The read builtin pauses a script and waits for the user to type something, storing it in a variable.
- [[Command substitution]] — Command substitution runs a command and captures its output into a variable or string, using $(...).
- [[Quoting]] — Double quotes allow variable expansion inside them; single quotes treat everything literally, including $ signs. Unquoted variables can break on spaces.
- [[if]] — if runs a block of code only when a condition is true, using test expressions inside [ ] or [[ ]].
- [[elif]] — elif lets you check additional conditions if the first if was false, avoiding deeply nested if statements.
- [[else]] — else defines the fallback block that runs when none of the preceding if/elif conditions were true.
- [[case]] — case matches a value against a list of patterns, similar to switch statements in other languages, and is often cleaner than long if/elif chains.
- [[for]] — for loops iterate over a list of items — words, filenames, numbers, or command output — running commands once per item.
- [[while]] — while runs a block repeatedly as long as a condition remains true — useful for polling, reading input line by line, or waiting on a state.
- [[until]] — until is the inverse of while — it runs the block until a condition becomes true, i.e. while it's still false.
- [[Functions]] — Functions group commands into a reusable, named block, keeping scripts organized and avoiding repetition.
- [[Arguments]] — Arguments are values passed to a script or function when it's called, letting the same code run differently depending on input.
- [[$1, $2, $@, $#]] — $1, $2... refer to individual positional arguments. $@ expands to all arguments as separate words. $# gives the total argument count.
- [[Exit codes]] — Every command returns an exit code when it finishes: 0 means success, any non-zero value means some kind of failure, with meanings often specific to the command.
- [[$?]] — $? holds the exit code of the most recently executed command, and must be checked immediately — running any other command overwrites it.
- [[&&]] — && runs the next command only if the previous one succeeded (exit code 0) — a compact way to chain dependent steps.
- [[||]] — || runs the next command only if the previous one failed (non-zero exit code) — often used for fallback actions or error messages.
- [[Arrays]] — Bash arrays store multiple values in a single variable, indexed starting at 0, accessed and looped over with special syntax.
- [[String manipulation]] — Bash supports built-in string operations for length, substrings, and replacement without needing external tools for simple cases.
- [[Arithmetic]] — Bash performs integer arithmetic using $((...)) or the let builtin. It doesn't handle decimals natively — that requires external tools like bc or awk.
- [[File tests]] — File test operators check properties of a file or directory — whether it exists, is readable, is a directory, etc. — before acting on it.
