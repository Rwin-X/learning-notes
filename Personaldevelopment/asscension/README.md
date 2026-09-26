
# ASCENSION

> Small steps. Every day. Big results.

A minimal, dark-first personal-development journal that treats your year as a system. See all 365 days at a glance, open any day to log it, and lock finished days into a tamper-evident SHA-256 hash chain.

Zero dependencies. One HTML file. Runs in any modern browser.

---

## Features

### Year dashboard
- 12 months × 31 days grid showing the whole year at once
- Cell intensity reflects that day's **Mode** score (0–10); logged days carry a marker, today is outlined
- Live stats: day of year, days logged, current streak, average Mode
- Year progress bar and previous/next year navigation

### Daily entry
Click any day to open a full journal page:

| Section | Purpose |
|---|---|
| **Today is** | One line that defines the day |
| **Mode / 10** | Overall state score |
| **The Path** | Direction for the day or season |
| **Body / Focus / Health / Learning** | Four pillar trackers, each with a done-tick and a note |
| **Today's Plan** | Checkable task list |
| **Data / Intelligence** | Six bullet slots for insights |
| **Lessons Learned** | Three slots |
| **Quote** | Text plus author |
| **Notes** | Free-form note-taking |

Entries autosave. Use the arrows to move between days, `Esc` to close.

### Seal day: hash-chained ledger
Sealing a day locks it and links it to the previous sealed day, forming an append-only chain. Editing a sealed entry afterwards, whether in a backup file or in storage, breaks the chain, and **Verify chain** reports the exact day where it broke.

- Days must be sealed in chronological order
- Only the most recent seal can be removed
- Sealed days appear with a solid border on the year grid

### Signal: analytics on your own data
- **Pillar impact:** average Mode on days a pillar was done vs. skipped, with the delta (needs at least 3 days in each group)
- **Mode by weekday:** bar chart of your average Mode per weekday

### 3D backdrop
The page background renders your year as a rotating 3D helix on a `<canvas>` (pure 2D projection math, no libraries). Each day is a node on an ascending spiral:
- logged days glow brighter, sealed days become spinning wireframe cubes, today is ringed
- reacts to mouse movement (parallax) and scroll (rotation and rise)
- honours `prefers-reduced-motion` by rendering a static frame

### Data control
- **Export**: download everything as JSON
- **Import**: merge a backup into the current data (imported days overwrite the same dates)
- **Reset**: erase everything, guarded by a two-step confirmation (click, then confirm within 5 seconds)
- **Theme**: follows the system light/dark setting, with a manual toggle

---
To host it on **GitHub Pages**, rename `ascension.html` to `index.html`, then enable Pages from the repository settings.

---

## Data & storage

All data is stored in the browser's `localStorage` under the key `ascension-journal-v1`. It never leaves your device unless you export it.

- Clearing site data or switching browsers or devices loses the entries, so **export regularly**
- Backups are portable between any two copies of the app

### Day schema

```jsonc
{
  "2026-03-14": {
    "t": "Deep work day",            // Today is
    "m": 8,                          // Mode, 0–10
    "path": "",                      // The Path
    "b": "", "bd": 1,                // Body: note, done
    "f": "", "fd": 1,                // Focus
    "h": "", "hd": 0,                // Health
    "l": "", "ld": 1,                // Learning
    "plan": [{ "x": "Ship v1", "d": 1 }],
    "intel": ["", "", "", "", "", ""],
    "les": ["", "", ""],
    "q": "", "qa": "",               // Quote, author
    "n": "",                         // Notes
    "s": {                           // present only when sealed
      "h": "<sha256>",
      "p": "GENESIS",                // previous seal's hash
      "at": "2026-03-14T21:00:00.000Z"
    }
  }
}
```

### Export format

```json
{
  "app": "ascension",
  "version": 1,
  "exported": "2026-03-14T21:05:00.000Z",
  "data": { "2026-03-14": { } }
}
```

Import also accepts a bare `{ "YYYY-MM-DD": { ... } }` map.

---

## How sealing works

For each sealed day, in date order:

```
hash = SHA-256( previousHash + "|" + date + "|" + canonicalJSON(day without "s") )
```

- `previousHash` is `"GENESIS"` for the first sealed day
- `canonicalJSON` sorts object keys recursively, so the same content always yields the same hash
- **Verify chain** recomputes every seal from the start and checks each `p` link

**What this is:** tamper-*evidence*. Any change to a sealed entry or the order of the chain is detectable.
**What this is not:** encryption or access control. Entries are stored as plain text, and someone with access to your browser data could edit an entry and re-seal everything after it. Keep exported backups if you need an independent reference.

The hash chain relies on the Web Crypto API (`crypto.subtle`), which requires a secure context (`https://` or `file://` in modern browsers).

---

## Design notes

- Vanilla HTML, CSS and JavaScript in a single file, with no framework and no dependencies (the 3D scene is hand-written perspective projection on canvas)
- Minimal, monochrome, editorial aesthetic; theme tokens are CSS variables with light and dark palettes
- The Inter font loads from Google Fonts and falls back to the system font stack when offline
- Responsive: the year grid scrolls horizontally on narrow screens; the day view stacks to one column

---

## Roadmap

- [ ] Weekly and monthly review views
- [ ] Mode trend chart across the year
- [ ] Encrypted entries (AES-GCM, passphrase-derived key)
- [ ] Habit streaks per pillar
- [ ] Printable daily and yearly PDF layouts
- [ ] Keyboard command palette

---

## Project origin

Designed around a printable "Ascension 2026" daily planner page, then rebuilt as a yearly dashboard app. The hash-chained ledger and the Signal analytics were added to move it from a plain journal toward a personal operating system.

---

## License

Choose a license before publishing (for example MIT) and add a `LICENSE` file.
