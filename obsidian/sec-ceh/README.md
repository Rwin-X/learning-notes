# Cybersecurity Second Brain — Setup Guide

## 1. Install
1. Unzip this folder anywhere on disk.
2. Open Obsidian → "Open folder as vault" → select this folder.
3. Start at `00-Home.md` — pin it (right-click → Pin) so it's always your landing page.

## 2. Recommended Plugins
- **Dataview** — required for the live query tables in the MOCs (CTF list, tool list, study logs). Community Plugins → Browse → "Dataview" → Install → Enable.
- **Templater** (optional but recommended) — makes the `{{date}}` and `{{title}}` placeholders in `08-Templates/` auto-fill when you create a note from a template.
- **Excalidraw** (optional) — useful for freehand attack-chain diagrams, network topology sketches.

## 3. How the System Works
This is a **Zettelkasten + MOC hybrid**, the same pattern as your existing Obsidian vault:

- **`00-Inbox/`** — dump raw notes, half-formed thoughts, pasted terminal output here. Process weekly: either it becomes a permanent note or you delete it.
- **`01-MOCs/`** — Maps of Content. Hub notes that link out to everything in a domain. Start here when you don't know where to put something.
- **`02-Zettelkasten/`** — pure atomic concept notes that don't fit neatly into one domain folder, or that connect multiple domains.
- **`03-Domains/`** — domain-specific concept notes (Network Security, Web AppSec, Cryptography, etc.). Most of your permanent notes live here.
- **`04-Tools/`** — one note per tool (Nmap, Burp Suite, Wireshark...) using the Tool Note template.
- **`05-CTF-Labs/`** — writeups using the CTF Writeup template.
- **`06-Certifications/`** — CEH and Security+ subfolders for exam-domain-mapped notes and study logs.
- **`07-Projects/`** — one note per devforge project, documenting architecture and linking back to the concepts it uses.
- **`08-Templates/`** — the five templates below. Use Obsidian's "Insert Template" command (Ctrl/Cmd+P) or set up Templater hotkeys.
- **`09-Sources/`** — where you learned something, so notes stay traceable.

## 4. The Five Templates
| Template | Use For |
|---|---|
| Concept Note | Any single idea, technique, protocol, or attack |
| Tool Note | Any piece of software you use |
| CTF Writeup | Any lab, box, or CTF challenge |
| Study Log | Daily/session-based cert prep tracking |
| Project Note | Any devforge build |

## 5. Daily Workflow
1. Studying or building something → open Inbox, jot raw notes fast, don't format.
2. End of session → promote anything worth keeping into a proper note using the right template, drop it in the correct domain folder.
3. Link it into at least one MOC. No orphans.
4. If it's cert-related, log the session with the Study Log template and link it from the CEH or Security+ MOC.

## 6. What's Already Populated
To show the pattern rather than leave you with empty folders, this vault ships with:
- Full MOC structure (8 domain MOCs + 2 cert MOCs + projects/tools/sources/CTF MOCs)
- 5 ready-to-use templates
- 2 fully worked concept notes (`AES-256-GCM`, `Argon2id Key Derivation`) showing the depth level to aim for
- 2 fully worked project notes (`secNT`, `HoneyShield`) showing how to document your own tools
- A CSS snippet matching your phosphor-terminal aesthetic

Everything else referenced in the MOCs (e.g. `[[SQL Injection]]`, `[[Nmap]]`) is an intentional **stub link** — click it in Obsidian and it'll prompt you to create that note. That's the system working as designed: the MOCs define the shape of your knowledge before you've filled it in, and clicking through stub links is literally how you build the vault out over time.

## 7. Suggested First Session
1. Open Graph View, confirm you can see the MOC web.
2. Pick one domain you're actively studying (probably CEH-aligned recon or network security).
3. Click through 3–4 stub links from that MOC and fill them in using the Concept Note template.
4. Log the session with a Study Log note.
