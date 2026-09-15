---
tags: [bash-course, concept, level-02]
level: "[[02 Core Scripting]]"
---

# Arguments

> Arguments are values passed to a script or function when it's called, letting the same code run differently depending on input.

## Syntax
```bash
./script.sh arg1 arg2
```

## Example
```bash
$ cat greet.sh
#!/bin/bash
echo "Hello, $1"
$ ./greet.sh Rwin
```

## Expected output
```
Hello, Rwin
```

## ⚠️ Common mistake
Assuming an argument was provided without checking — accessing $1 when nothing was passed just gives an empty string, not an error.

## 💡 Practical use
Nearly every real-world script accepts arguments: a filename to process, an environment name, a flag to control behavior.

## Notes

## Related
- [[02 Core Scripting]]
- [[Bash Cheat Sheet]]
