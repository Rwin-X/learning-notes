---
title: "README"
tags:
  - readme
---

# Python Second Brain — Setup

## 1. Open in Obsidian
1. Open **Obsidian** → `Open folder as vault` → select this `vault` folder (the one containing this README and the `.obsidian` folder).
2. Obsidian will index all 61 notes automatically.

## 2. Start here
Open **`00-MOC/00-Home.md`** — it's the front door to the whole vault.

## 3. Graph View
Press `Ctrl/Cmd + G` to open Graph View. Color groups are **pre-configured** for you:

| Tag | Color |
|---|---|
| `#easy` | Green |
| `#medium` | Yellow |
| `#hard` | Orange |
| `#expert` | Red |
| `#security` | Purple |
| `#project` | Blue |
| `#moc` | White |

If colors don't appear immediately, open Graph View → the gear/settings icon → **Groups** — they're already saved in `.obsidian/graph.json`, but Obsidian sometimes needs the panel opened once to apply them.

## 4. Folder structure
```
00-MOC/              → hub notes (start here)
01-Beginner/          🟢 easy
02-Intermediate/       🟡 medium
03-Advanced/            🟠 hard
04-Expert/                🔴 expert
05-Security-Track/    🟣 CEH / Security+ / devforge-style tooling (mixed difficulty)
06-Projects-Labs/      🔵 hands-on labs tying it all together
```

## 5. Recommended workflow
- Follow **`00-Learning-Path-MOC`** in order — it has checkboxes (`- [ ]`) you can tick off as you complete each topic.
- Once you finish a stage, jump into the matching lab in **`06-Projects-Labs`**.
- Use **`00-Security-Track-MOC`** as your dedicated CEH/Security+ path — it explicitly maps back to your own `devforge` projects (secNT, HoneyShield, NetViz, inOs, METAINSPECT, etc.)

## 6. Extending it
This vault is plain Markdown + YAML frontmatter — no plugins required. To add a new note:
```markdown
---
title: "New Topic"
difficulty: medium
tags:
  - medium
  - your-topic-tag
---

# New Topic

`🟡 MEDIUM` #medium

content here...

## Related
- [[Existing Note]]
```
Drop it in the right difficulty folder and link it from at least one existing note — that's what keeps the graph connected instead of full of isolated islands.
