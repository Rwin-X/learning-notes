# Ruby Second Brain — Vault Guide

A complete Obsidian knowledge system for learning Ruby from absolute beginner to
advanced, built as **82 atomic notes + 9 Maps of Content**, fully cross-linked
with **zero orphan notes**.

Open this folder directly as an Obsidian vault (`Open folder as vault`). Start at
**`00-MOCs/Ruby MOC.md`**.

---

## How the vault is organized

```
00-MOCs/          Hub notes — the master map + one MOC per domain
01-Foundations/   Syntax, variables, types, control flow, methods, blocks
02-OOP/           Classes, inheritance, modules, mixins, Comparable/Enumerable
03-Collections/   Arrays, hashes, iterators, the Enumerable method family
04-Advanced/      Closures, exceptions, file IO, regex, concurrency, GC
05-Metaprogramming/  method_missing, define_method, class_eval, reflection
06-Ecosystem/     Bundler, gems, RSpec, Rake, Rubocop, Rails, version managers
07-Projects/      6 progressively harder mini-projects → capstone
08-Exercises/     Practice problem sets, one per stage
09-Cheatsheets/   Fast-lookup reference notes (not for learning, for recall)
10-Resources/     Books, docs, communities
99-Templates/     Note template for adding your own atomic notes
```

Numeric prefixes keep the sidebar in learning order. `00-MOCs` sorts first
because it's your navigation layer — always the way in.

## The atomic note pattern

Every concept note (not MOCs, not cheatsheets) follows the same six-section
schema:

1. **Purpose** — why this concept exists, in 1-2 sentences
2. **Explanation** — the teaching, written to link outward generously
3. **Examples** — a minimal runnable Ruby snippet
4. **Related Notes** — lateral connections (concepts at a similar level)
5. **Next Topics** — forward connections (what to learn next)
6. **Tags** — hierarchical tag for filtering and graph coloring

This consistency is deliberate: once you know the shape, you can scan any note
in seconds, and it's what keeps the graph dense rather than tree-like — nearly
every note links to 3-5 others, not just its parent MOC.

## Tag taxonomy

```
#ruby/basics            Foundations-level notes
#ruby/oop                Object-oriented programming
#ruby/collections        Arrays, hashes, Enumerable
#ruby/advanced            Closures, exceptions, IO, regex, concurrency
#ruby/metaprogramming     method_missing, define_method, eval, reflection
#ruby/ecosystem            Bundler, gems, testing, Rails, tooling
#project                   Hands-on builds
#exercise                  Practice problem sets
#cheatsheet                Fast-reference notes
#resource                  Books, docs, communities
```

Use the **Tags pane** (left sidebar) to filter by any of these, or click a tag
inline in any note.

## Graph View color groups

Pre-configured in `.obsidian/graph.json` — open Graph View and the colors are
already set by folder path:

| Color role | Folder | Theme |
|---|---|---|
| White | `00-MOCs` | Navigation hubs |
| Blue | `01-Foundations` | Core language |
| Purple | `02-OOP` | Object orientation |
| Green | `03-Collections` | Data structures |
| Orange | `04-Advanced` | Deep mechanics |
| Violet | `05-Metaprogramming` | Runtime magic |
| Teal | `06-Ecosystem` | Tooling & community |
| Red/Pink | `07-Projects` | Applied builds |
| Yellow | `08-Exercises` | Practice |
| Gray-blue | `09-Cheatsheets` | Reference |
| Gray | `10-Resources` | External links |

**Recommended Graph View settings** (already saved, but to hand-tune):
Settings icon in Graph View → increase **Node size** slightly for MOCs by
searching `path:00-MOCs` in the "Groups" filter, and enable **"Show tags"** to
also see the tag layer as its own node cluster.

## The learning path

Follow **[[Roadmap]]** for the guided sequence. Short version:

1. **Foundations** → do exercises → build the guessing game + todo app
2. **OOP + Collections in parallel** → exercises → 3 intermediate projects
3. **Advanced + Metaprogramming** → exercises → capstone contact book project
4. **Ecosystem** → testing, tooling, Rails — bridge to real-world dev

## Extending the vault

Use `99-Templates/Atomic Note Template.md` (Templates core plugin, already
enabled — set the template folder to `99-Templates` in Settings → Templates if
it isn't already detected) to add new notes in the same schema. When you add a
note:

- Give it **at least 2 outgoing links** to existing notes (prevents orphans)
- Add it to the relevant MOC's list
- Tag it with the matching `ruby/*` hierarchy tag
- If it's a new domain entirely, add a new color group in Graph View settings

## Why this structure produces a dense graph

Every note was written with **Related Notes** and **Next Topics** pointing to
real neighbors — not just "back to MOC." OOP notes reference Collections notes
(`Enumerable Module` ↔ `Enumerable Deep Dive`), Advanced notes reference
Foundations (`Closures` ↔ `Blocks Basics`), and Projects notes pull threads
from 3-4 domains at once. That's what turns Graph View from a spoke-and-hub
pattern into visible, organic clusters.
