---
title: "Logging"
difficulty: medium
tags:
  - medium
  - tooling
  - intermediate
---

# Logging

`🟡 MEDIUM` #medium

## What it covers
The `logging` module instead of scattering `print()` everywhere.

## Key points
- Log levels: `DEBUG < INFO < WARNING < ERROR < CRITICAL`
- Configure once at the top of your app: `logging.basicConfig(level=logging.INFO)`
- Essential for any long-running tool (honeypots, monitors) where you need a real audit trail

## Practice
Replace all `print()` debug statements in one existing project with proper `logging` calls.


## Related
- [[Exception Handling]]
- [[Working with CLI Arguments (argparse)]]
