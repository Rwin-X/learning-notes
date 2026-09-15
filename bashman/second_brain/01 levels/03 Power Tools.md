---
tags: [bash-course, level, level-03]
---

# 03 Power Tools

> grep, sed, awk, and pipes are what turn Bash from a scripting language into the sharpest text-processing toolkit in Linux. This level is where you start feeling genuinely fast.

| Field | Value |
|---|---|
| Difficulty | Intermediate |
| Time | ~5–7 hours |
| Skills gained | pipes, text processing, regex |
| Prerequisites | Levels 01–02 |
| Final challenge | Rank top IPs from a log in one pipeline |

## Concepts

- [[Pipes]] — The pipe (|) sends the output of one command directly into the input of the next, letting you chain small tools into a larger operation.
- [[Redirection]] — Redirection sends command output to a file (>) or appends to it (>>) instead of the screen, and can also feed a file in as input (<).
- [[grep]] — grep searches text for lines matching a pattern, and is one of the most-used commands in all of Linux administration and security work.
- [[find]] — find searches the filesystem for files and directories matching criteria like name, type, size, or modification time.
- [[sort]] — sort arranges lines of text alphabetically or numerically. -n sorts numerically, -r reverses the order.
- [[uniq]] — uniq removes adjacent duplicate lines. It only works correctly on sorted input, so it's almost always paired with sort first.
- [[cut]] — cut extracts specific columns or fields from each line of text, based on a delimiter or fixed character positions.
- [[tr]] — tr translates or deletes individual characters from input — useful for case conversion, removing characters, or squeezing repeats.
- [[wc]] — wc counts lines, words, and characters/bytes in text. -l for lines is the most commonly used flag.
- [[xargs]] — xargs builds and runs commands using input from another command's output, useful for commands that don't accept piped input directly.
- [[sed]] — sed is a stream editor that transforms text line by line, most commonly used for find-and-replace directly in files or piped streams.
- [[awk]] — awk is a full pattern-scanning and text-processing language, most often used to extract and compute values from column-based data.
- [[Regular expressions]] — Regular expressions (regex) describe text patterns to match, using metacharacters like . * ^ $ [ ] to represent flexible rules rather than exact text.
- [[Text processing]] — Combining grep, cut, sort, sed, and awk in a pipeline is how most real-world text processing gets done in Bash, without writing custom code.
- [[Command chaining]] — Beyond pipes, commands can be chained with ; (run regardless), && (run if success), and || (run if failure) to control execution flow on one line.
