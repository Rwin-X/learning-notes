---
tags: [bash-course, level, level-01]
---

# 01 Foundation

> Before you write a single script, you need to be dangerous on the command line. This level gets you comfortable navigating and manipulating a Linux filesystem by hand.

| Field | Value |
|---|---|
| Difficulty | Beginner |
| Time | ~3–4 hours |
| Skills gained | navigation, file ops, reading files |
| Prerequisites | none |
| Final challenge | Build a folder tree from scratch using only commands |

## Concepts

- [[What is Bash?]] — Bash (Bourne Again SHell) is a program that reads the commands you type and asks the operating system to run them. It's the default command-line interpreter on almost every Linux system and macOS (until Catalina).
- [[Shell vs Terminal]] — The terminal is the window (the display). The shell is the program running inside it that actually interprets your commands. Bash is one kind of shell.
- [[Bash vs other shells]] — sh is the original, minimal POSIX shell. Bash extends it with more features (arrays, [[ ]], string manipulation). zsh and fish add further conveniences but aren't always installed by default on servers.
- [[Running commands]] — A command is a program name, optionally followed by arguments and flags, that you run by typing it and pressing Enter.
- [[Command structure]] — Most Unix commands share a predictable shape: the command itself, single or double-dash flags to modify behavior, and arguments telling it what to act on.
- [[Linux filesystem]] — Linux has a single unified directory tree starting at / (root). Everything — disks, devices, configs — lives somewhere under it. There's no C:\ style drive letters.
- [[pwd]] — pwd prints your current working directory — where you are right now in the filesystem tree.
- [[ls]] — ls lists the contents of a directory. Combined with flags, it can show hidden files, sizes, permissions, and modification times.
- [[cd]] — cd changes your current working directory. Used with no arguments, it takes you to your home directory.
- [[mkdir]] — mkdir creates new directories. The -p flag creates any missing parent directories along the way instead of erroring out.
- [[touch]] — touch creates an empty file if it doesn't exist, or updates its modification timestamp if it does.
- [[cp]] — cp copies files or directories. Use -r (recursive) to copy an entire directory tree.
- [[mv]] — mv moves files or directories, and is also how you rename something in Bash — there is no separate rename command.
- [[rm]] — rm permanently deletes files. There is no trash bin — deleted means gone. -r deletes directories recursively, -f forces deletion without prompts.
- [[cat]] — cat prints the entire contents of one or more files to the screen. It's also used to concatenate multiple files together.
- [[less]] — less opens a file for scrollable, searchable viewing without loading the whole thing into your terminal at once — ideal for large files.
- [[head / tail]] — head shows the first lines of a file (default 10); tail shows the last lines. tail -f follows a file live as new lines are appended.
