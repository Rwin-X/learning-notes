# Emergence and Diffusion

Three single-file browser demos. No build step, no dependencies, no network calls apart from web fonts.

| File | What it is |
| --- | --- |
| `physarum.html` | GPU slime-mold simulation: up to about 1M agents, three species with their own temperaments and a selectable ecology, agents that scout when hungry, grows any typed text, WebGL2 |
| `avalanche.html` | SHA-256 avalanche effect, traced round by round for a one-bit input change |
| `flowfield.html` | Earlier sketch: particles in a noise flow field on Canvas 2D |

## Run

Open any file in a modern browser. If you prefer serving it:

```
python3 -m http.server 8000
```

`physarum.html` needs WebGL 2 and the `EXT_color_buffer_float` extension. If either is missing the page says so instead of failing silently.

---

## Physarum

### Model

Each agent has a position, a heading, a species id and an energy level. Every step an agent:

1. **Feeds or starves.** It reads its own species' trail under its feet (and the food map, if text is set). Rich ground raises its energy, poor ground lowers it. The feeding scale is normalized by the expected mean trail level, so behavior does not depend on agent count or decay.
2. **Looks around at two ranges.** It scores three directions (straight, left, right of the sensor angle). Each direction is scored at the sensor distance and again at 2.6 times that distance, and the far score is weighted by Vision.
3. **Scores with its ecology.** The score of a direction is the sum, over the three trails, of `weight * trail`, plus the food term. The weight on its own trail is 1. The weights on the other two come from the selected ecology, scaled by Interaction.
4. **Decides.** A hungry agent (low energy) scouts with probability up to 0.55 times its hunger times Curiosity: it ignores the map and turns randomly. Otherwise it turns toward the higher score by the turn angle. If straight ahead is the weakest it turns randomly left or right, and if straight ahead is the strongest it keeps going.
5. **Moves.** Hungry agents also move faster, up to 70% at full hunger and full Curiosity. The world wraps at the edges.
6. **Deposits.** Well-fed agents deposit more (0.35 up to 1.25 units, blended in by Curiosity), so fed agents reinforce the network and scouts leave faint marks.

Ecologies (row = the species that is looking, weights are for trails of species 0, 1, 2):

| Ecology | Off-diagonal weights | Behavior |
| --- | --- | --- |
| Rivals | all -1 | Species avoid each other's trails and partition territory, the original behavior |
| Chase | species i chases the trail of i+2 (+1) and flees the trail of i+1 (-1) | Rock-paper-scissors pursuit. In testing the species merge into bundled cables with fine branching |
| Symbiosis | all +1 | Species follow each other and co-locate |
| Ignore | all 0 | Three independent networks drawn on top of each other |

The trail map is blurred with a 3x3 mean (mixed by the diffusion amount) and multiplied by `1 - decay` after every step. Three species map to the R, G and B channels of one texture.

### GPU pipeline

No compute shaders, only WebGL2 fragment shaders and point sprites.

| Pass | Reads | Writes | How |
| --- | --- | --- | --- |
| Agent update | agent texture, trail texture | next agent texture | full-screen triangle, one texel per agent |
| Deposit | agent texture | trail texture | `gl.POINTS`, one vertex per agent, position fetched with `texelFetch` from `gl_VertexID`, additive blending, amount scaled by the agent's energy |
| Diffuse and decay | trail texture | next trail texture | 3x3 blur, decay, and the pointer's feeding splat |
| Display | trail texture | screen | tone mapping, a small four-tap glow, vignette, film grain |

Textures:

- Agents: `RGBA32F`, nearest filtering. Channels are x, y, heading, and species plus energy packed into one float (the integer part is the species, the fractional part is the energy).
- Trail: `RGBA16F`, linear filtering, repeat wrap. Half-float blending is what makes additive deposit work without extra extensions.
- Both are ping-ponged.

Randomness comes from a PCG hash of the agent id and the frame counter, computed in the shader.

### Controls

| Control | Effect |
| --- | --- |
| Sensor angle | How far apart the three sensors point. Small values give long straight veins, large values give cells and blobs |
| Turn angle | How sharply an agent reacts |
| Sensor distance | Look-ahead in pixels. Scaled by canvas width so a preset looks similar on different screens |
| Speed | Pixels per step (also scaled) |
| Decay | How fast trails fade |
| Diffusion | How much trails bleed into neighbors |
| Interaction | Strength of the ecology's cross-species weights. 0 makes every ecology behave like Ignore |
| Vision | Weight of the far look. 0 gives the classic single-range model |
| Curiosity | How much hunger drives scouting, extra speed and weaker deposits. 0 turns the energy system off |
| Exposure | Display gain only, does not affect the simulation |
| Personalities | 0 makes the three species identical. Higher values give each its own sensor angle, turn angle, sensor distance and speed, so they build visibly different structures |
| Food strength | How strongly agents are drawn toward the typed text |
| Time scale | Simulation steps per rendered frame |

Presets are Veins, Cells, Web, Bloom and Storm. Chaos drifts the sensor and turn angles with slow sine waves.

Grow text: type a word (up to 24 characters, any script the browser can shape, including Persian) and the colony grows into it. The text is drawn on a 2D canvas, blurred slightly, uploaded as a single-channel attractant map, and added to every sensor's score, so agents of all species are pulled onto the glyphs while rivalry still keeps them from sharing space evenly. "Show the text outline" adds a faint guide so you can see the target shape.

Save frame: writes the current canvas to a PNG. The button hides itself when the page is embedded in a sandboxed viewer, where downloads do not work.

Pointer: hovering scatters nearby agents, holding attracts them and adds trail for the selected brush species. Keys: `Space` pause, `R` reseed (cycles start patterns), `1` to `5` presets, `B` brush, `E` ecology, `S` save frame, `H` hide interface.

### Performance notes

- Cost scales with agent count (deposit is one point per agent) and trail resolution (diffuse is one pass over every pixel).
- The trail map is capped at about 1.3 megapixels, and the device pixel ratio at 1.5.
- Defaults to 262,144 agents on desktop and 65,536 on touch devices. The agent count is selectable up to 1,048,576.

### Status

Tested during authoring in headless Chromium with software WebGL2 (SwiftShader): all shaders compile and link, there are no runtime errors, the three species form vein networks, typed English and Persian text (shaped correctly) pulls the colony into the word, and the Rivals and Chase ecologies both run with Vision and Curiosity enabled and produce clearly different structures (separated lanes with scouts and hubs, versus bundled cables). Symbiosis and Ignore were not visually checked. Software rendering ran at about 2 frames per second, so this confirms correctness only, not real-GPU speed or tuning.

The preset values follow published slime-mold model conventions and were only eyeballed on the Veins preset. If the image is too bright or too dark, adjust Exposure first. If another preset looks off, tune sensor angle, sensor distance and decay, in that order. If a shader ever fails to compile on your hardware, the page shows the driver's message.

---

## Avalanche

### What it shows

Pick one input bit to flip. The page runs SHA-256 on both messages, records the eight working variables `a` to `h` after each of the 64 rounds, and XORs the two runs. Each row of the heat map is one round, each column is one of the 256 state bits, and a bright cell means the two runs differ there.

### Implementation

- A from-scratch SHA-256 that returns the full round trace (`states[0..64]`) and the digest.
- Single 512-bit block only, so messages are limited to 55 bytes (55 message bytes, one `0x80` padding byte, 8 length bytes).
- Bit numbering: bit 0 is the most significant bit of the first byte.
- Hamming distances use a 32-bit popcount.
- The "every possible flip" histogram hashes the message once per input bit and compares each digest with the original. The overlaid curve is the ideal `Binomial(256, 0.5)` scaled by the number of flips.

### Verification

Checked during authoring with Node:

| Test | Result |
| --- | --- |
| NIST vector `abc` | pass |
| Empty string | pass |
| `The quick brown fox jumps over the lazy dog` | pass |
| 200 random messages of 0 to 55 bytes against Node's `crypto` | 0 mismatches |

At runtime the page also compares both digests with `crypto.subtle` and shows the outcome at the bottom. If Web Crypto is unavailable it falls back to the NIST vector.

### Measured behavior

For the default message with the first bit flipped, the number of differing state bits per round was:

```
round:    0   1   2   3   4    5    6    7    8
differ:   0   2  16  42  80  110  128  130  124
```

So the change reaches roughly half of the 256-bit state by round 6. Over every single-bit flip of that message, the mean digest difference was 127.61 of 256 bits, which is what a fair coin per bit would give (128, with a standard deviation of 8).

### Limits

- One block only. Longer inputs would need the trace of a chosen block, which is not implemented.
- The heat map shows the working state, not the message schedule `W`. Showing `W` as a second map would be a natural extension.

---

## Ideas for extending

- Physarum: mouse-drawn obstacles, an image or drawn shape as the food map, per-species colors and full per-species parameter sliders, recording to video.
- Avalanche: message schedule map, other hash functions for comparison (SHA-1, MD5, a weak toy hash), a diffusion score per round.
- Both: a shared landing page and a short write-up of the algorithms.
