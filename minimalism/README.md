

A growing collection of self-contained, client-side tools that make the hidden structure of data visible.

Data carries structure that tables and hex dumps hide. Each project here takes one kind of input (text, a file, a packet capture), computes something real from it (a digest, an entropy profile, a hash tree, a conversation graph), and renders the result as a minimal, interactive 3D scene that can be rotated, hovered and interrogated. The same input always produces the same picture, and every visual element traces back to a value in the data.

## Core idea

1. **Real computation, not decoration.** Every mark on screen maps to something concrete: a bit, a byte, a block of a file, a packet. Hovering or clicking shows the source value. Where a project computes something verifiable (a hash, a Merkle root, an entropy figure, a parsed capture), the result is checked against an independent implementation.
2. **Deterministic.** Same input, same output. The only randomness is in clearly labeled sample data.
3. **Local and self-contained.** Each project is a single HTML file: no build step, no server, no dependencies. Files and captures are read in the browser and never uploaded. The only network request is an optional web font, with a system-font fallback.
4. **Minimal, monochrome design.** One foreground and background pair, dark by default with a light toggle, hairline rules, one oversized wordmark. Motion appears only when it carries information, and `prefers-reduced-motion` is respected.
5. **Honest results.** Heuristics are labeled as heuristics. A port-scan flag or an entropy verdict is a hint for the analyst, not a finding.
