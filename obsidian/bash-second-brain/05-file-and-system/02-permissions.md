
---
tags: [filesystem, bash]
aliases: [chmod, chown, permissions]
---

# Permissions

## Reading `ls -l` Output

```
-rwxr-xr-- 1 rwin staff 4096 Aug 25 10:00 script.sh
```

| Segment | Meaning |
|---|---|
| `-` (1st char) | File type: `-`=file, `d`=directory, `l`=symlink |
| `rwx` | Owner permissions: read, write, execute |
| `r-x` | Group permissions |
| `r--` | Others (everyone else) permissions |

## `chmod` — Changing Permissions

### Symbolic mode
```bash
chmod +x script.sh        # add execute for everyone
chmod u+x script.sh        # add execute for owner (user) only
chmod g-w file.txt          # remove write for group
chmod o=r file.txt          # set others to read-only exactly
chmod u+rwx,g+rx,o+r file   # combine multiple targets
```

### Numeric (octal) mode

Each permission is a bit: read=4, write=2, execute=1. Sum them per
category (owner, group, other):

```bash
chmod 755 script.sh
# 7 = rwx (owner: 4+2+1)
# 5 = r-x (group: 4+0+1)
# 5 = r-x (other: 4+0+1)

chmod 644 file.txt
# 6 = rw- (owner)
# 4 = r-- (group)
# 4 = r-- (other)
```

Common presets:
| Octal | Meaning | Typical use |
|---|---|---|
| `755` | rwxr-xr-x | Executable scripts, directories |
| `644` | rw-r--r-- | Regular data files |
| `600` | rw------- | Private files (SSH keys, secrets) |
| `700` | rwx------ | Private executable/directory |

## `chown` — Changing Ownership

```bash
chown rwin file.txt              # change owner
chown rwin:staff file.txt         # change owner AND group
chown -R rwin:staff /some/dir     # recursively for a whole directory tree
```
Usually requires `sudo` unless you already own the file.

## Why This Matters for Scripting

- A script needs `+x` to run directly (see
  [[01-fundamentals/02-shebang-and-execution|Shebang & Execution]]).
- Secrets/credentials files should be `600` — never world-readable.
- Security-relevant scripts should check permissions before trusting
  file content (see [[01-file-tests|File Tests]] for the `-r`/`-w`/`-x` checks).

```bash
perm=$(stat -c "%a" secret.key)
if [[ "$perm" != "600" ]]; then
    echo "WARNING: secret.key permissions are too open ($perm)"
fi
```

---

## Links
- Previous: [[01-file-tests]]
- Next: [[03-process-basics]]
- Related: [[01-fundamentals/02-shebang-and-execution|Shebang & Execution]]
- Hub: [[00-MOC]]
