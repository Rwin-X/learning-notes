# devforge

A growing collection of self-contained, client-side tools that make the hidden structure of data visible.

Data carries structure that tables and hex dumps hide. Each project here takes one kind of input (text, a file, a packet capture), computes something real from it (a digest, an entropy profile, a hash tree, a conversation graph), and renders the result as a minimal, interactive 3D scene that can be rotated, hovered and interrogated. The same input always produces the same picture, and every visual element traces back to a value in the data.

## Core idea

1. **Real computation, not decoration.** Every mark on screen maps to something concrete: a bit, a byte, a block of a file, a packet. Hovering or clicking shows the source value. Where a project computes something verifiable (a hash, a Merkle root, an entropy figure, a parsed capture), the result is checked against an independent implementation.
2. **Deterministic.** Same input, same output. The only randomness is in clearly labeled sample data.
3. **Local and self-contained.** Each project is a single HTML file: no build step, no server, no dependencies. Files and captures are read in the browser and never uploaded. The only network request is an optional web font, with a system-font fallback.
4. **Minimal, monochrome design.** One foreground and background pair, dark by default with a light toggle, hairline rules, one oversized wordmark. Motion appears only when it carries information, and `prefers-reduced-motion` is respected.
5. **Honest results.** Heuristics are labeled as heuristics. A port-scan flag or an entropy verdict is a hint for the analyst, not a finding.

## Projects

| Project | File |
| --- | --- |
| SIGIL | [`projects/sigil.html`](projects/sigil.html) |
| ENTROPY | [`projects/entropy.html`](projects/entropy.html) |
| MERKLE | [`projects/merkle.html`](projects/merkle.html) |
| FLOWS | [`projects/flows.html`](projects/flows.html) |

New projects are added over time. This table is the index.

## Screenshots

*(add screenshots here once you've generated them)*

## Requirements

A current browser with Canvas 2D, `Path2D`, the Web Crypto API and CSS `color-mix()`. All evergreen browsers have supported these since 2023.

Hashing uses Web Crypto, which browsers expose only in secure contexts (`https://`, `http://localhost`, and local files in most browsers). If hashing fails, serve the folder locally:

```bash
cd projects
python3 -m http.server 8000
# open http://localhost:8000/
```

## Usage

Open any file from `projects/` in a browser. The interaction model is shared across projects.

| Action | How |
| --- | --- |
| Rotate | Drag |
| Zoom | Mouse wheel, or pinch on touch screens |
| Reset view | Double-click |
| Pause | Space |
| Inspect | Hover or click an element |
| Load your own data | Drop a file anywhere, or use the File button |
| Switch theme | Theme button |
| Export an image | PNG button |

Individual projects add their own controls on top of these.

## Repository layout

```
devforge/
├── README.md
├── LICENSE
└── projects/
    ├── sigil.html
    ├── entropy.html
    ├── merkle.html
    └── flows.html
```

## Adding a project

New work follows the same conventions so the collection stays coherent:

- One self-contained HTML file in `projects/`, with no build step.
- All code, comments and interface text in English. No emojis.
- Derive visuals from data, and expose the underlying value on hover or click.
- Verify parsers and calculations against an independent implementation, and state plainly what could not be verified.
- Label sample data as synthetic and heuristics as heuristics.
- Use the shared design tokens:

| Token | Dark | Light |
| --- | --- | --- |
| `--bg` | `#0a0a0a` | `#f6f6f4` |
| `--fg` | `#f2f2f0` | `#0c0c0c` |
| `--mut` | `#77776f` | `#8a8a86` |
| `--line` | `#252525` | `#d9d9d5` |

- Add the project to the table above.

## License

MIT, see [LICENSE](LICENSE).
