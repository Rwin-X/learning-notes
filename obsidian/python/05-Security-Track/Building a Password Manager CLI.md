---
title: "Building a Password Manager CLI"
difficulty: hard
tags:
  - hard
  - security
  - project
---

# Building a Password Manager CLI

`🟠 HARD` #hard

## What it covers
Tying together [[Symmetric Encryption with cryptography lib]] + [[File IO]] + [[Working with CLI Arguments (argparse)]] into a complete secure CLI tool — directly relevant to your unfinished PyQt6 password manager.

## Key points
- Master password → Argon2id → derived key → AES-256-GCM encrypt/decrypt of a vault file
- Never log or print the master password or derived key, even in debug mode
- Clear sensitive variables from memory where practical (Python can't guarantee this fully, unlike C, but it's still good hygiene)

## Practice
Finish the CLI version first (simpler than GUI), then port the working crypto core into your paused PyQt6 project.


## Related
- [[Symmetric Encryption with cryptography lib]]
- [[File IO]]
- [[Working with CLI Arguments (argparse)]]
