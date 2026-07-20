# Melodic Techno Second Brain — Setup

## How to open this in Obsidian
1. Download and unzip `melodic-techno-vault.zip` somewhere permanent (e.g. `~/Documents/melodic-techno-vault`).
2. Open Obsidian → **Open folder as vault** → select the unzipped `melodic-techno-vault` folder.
3. A Graph View config is already included (`.obsidian/graph.json`), so Graph View should open pre-colored by folder:
   - **Genres** — one color
   - **Artists** — another
   - **Labels** — another
   - **Tracks** — another
   - **Techniques** — another
   - **MOC/hub notes** (the two Map-of-Content files) — white, so they stand out as anchor nodes

## Where to start
- Open **`Melodic Techno MOC.md`** first — it's the hub note. Everything radiates from there.
- Open **Graph View** (icon in the left ribbon, or `Ctrl/Cmd+G`) to see the whole web.
- Click any node in Graph View to jump to that note.

## Folder structure
```
melodic-techno-vault/
├── Melodic Techno MOC.md       ← start here
├── Timeline.md
├── Genres/                     ← 12 genre notes (core + adjacent + historical root)
├── Artists/                    ← 14 artist notes (detailed for core, brief for roster)
├── Labels/                     ← 6 label notes
├── Tracks/                     ← 3 key-track notes
└── Techniques/                 ← 7 production-technique notes + MOC
```

## Extending it yourself
- New artist → drop a `.md` file in `Artists/`, link it with `[[Artist Name]]` from a genre or label note, and it'll appear in the graph automatically on next Obsidian reload.
- Want deeper coverage of a specific artist, subgenre, or era (e.g. a full Afterlife roster page, or a dedicated Trance/Psytrance branch)? Just add notes following the same pattern — genre notes link out to Artists/Labels/Tracks/Techniques, and everything links back to its genre.
- Consider installing the **Dataview** or **Juggl** community plugins later if you want the graph to support filtering/queries (e.g. "show me all artists on Afterlife") beyond what stock Graph View offers.

## Sourcing note
Genre/artist/label facts here were pulled from current web sources (Beatportal 2025 year-end charts, genre reference sites, DJ Mag, and production guides) as of July 2026, not from memory alone — the melodic techno scene moves fast, so treat this as a living document and re-verify anything time-sensitive (chart rankings, "most-booked" claims, etc.) periodically.
