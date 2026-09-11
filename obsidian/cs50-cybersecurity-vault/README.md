# CS50 Introduction to Cybersecurity — Obsidian Vault

A Zettelkasten-style second brain for Harvard's CS50 Introduction to
Cybersecurity (David J. Malan), built as atomic, interlinked notes rather
than one long document per week. Content is based on the official
syllabus topic lists at cs50.harvard.edu/cybersecurity — verify against
the live site for any updates, since problem sets and minor topic
wording occasionally change between terms.

## How to open this in Obsidian

1. Open Obsidian → "Open folder as vault" → select this folder
   (`cs50-cybersecurity-vault`).
2. Start from `_MOCs/CS50 Cybersecurity MOC.md` — it links out to every
   week.
3. Open the graph view (the graph icon in the left ribbon, or
   `Ctrl/Cmd+G`) to see the whole thing visually. You should see five
   week clusters, with the `_MOCs` cross-cutting concepts sitting in the
   middle connecting all of them, and cross-week links (e.g. Week 0's
   Phishing linking forward to Week 3's injection attacks) forming
   visible bridges between clusters.

## Structure

```
_MOCs/                  Top-level index + cross-cutting concepts
0-Securing-Accounts/    Week 0 — authentication, passwords, 2FA, social engineering
1-Securing-Data/        Week 1 — hashing, cryptography, encryption
2-Securing-Systems/     Week 2 — networks, HTTPS/TLS, firewalls, malware
3-Securing-Software/    Week 3 — injection attacks, validation, vulnerability research
4-Preserving-Privacy/   Week 4 — tracking, cookies, DNS, VPN/Tor
_Templates/             Template for adding your own notes
```

Every concept note is short and single-idea (true Zettelkasten style),
with a "Up: [[Week MOC]]" link back to its week, and `[[wikilinks]]`
sideways to related concepts — including across weeks, since the course
deliberately builds each week on the last.

## Why it's organized this way

The course's own framing is that security isn't absolute — it's a
tradeoff (risk/reward for an attacker, cost/benefit for you, always
weighed against usability). That idea, plus "define your threat model
first" and "layer independent defenses," recur in every single week, so
they live as their own cross-cutting notes in `_MOCs/` rather than being
duplicated five times.

## Extending it

- Use `_Templates/concept-template.md` as a starting point for new notes
  — copy it, rename, fill in.
- When you add a note, link it into its week's MOC and consider what
  existing notes it should connect to sideways (that's most of the value
  of this structure over a plain outline).
- Assignment-specific notes (write-ups, code, gotchas from each problem
  set) fit well as new notes inside the relevant week's folder, linked
  from that week's MOC under a new "Assignment notes" section.

## A note on accuracy

Topic lists per week were pulled directly from the official CS50
Cybersecurity site (cs50.harvard.edu/cybersecurity/weeks/0 through /4) at
the time this vault was built. Explanatory content — how concepts connect,
why one leads to another — was written to match how the course frames
things, but is not a transcript of the lectures. Cross-check against the
actual lecture and shorts for anything assignment-critical.
