# THE EYE

A cinematic, procedurally generated **ASCII Eye of Sauron** that opens, watches, rages and closes, written in a single Python file.

It renders a detailed almond-shaped eye with a slit pupil, a fibrous iris, a fiery corona, drifting embers and an optional dark tower silhouette. Everything is drawn with text characters in a native desktop window.

<!-- Add a screenshot or GIF here:
![The Eye](docs/preview.gif)
-->

## Features

- **Cinematic sequence**: sleeping, awakening (with eyelid flutter), watching, periodic rage, closing, and back to sleep.
- **Living eye**: blinks (sometimes double), saccades, slow sweeping glances, a tiny tremor, and a pulsing pupil.
- **Interactive**: the eye follows your mouse cursor.
- **Rich detail**
  - Pointed slit pupil with a hot rim
  - Iris with coarse and fine fibres, crypts, a collarette ring and a limbal ring
  - Fiery sclera with veins and a halo around the iris
  - Lid shadows, glowing lid rims and lava cracks on the lids
  - Multi-layer flame tongues, volumetric god rays, bloom, vignette and an anamorphic lens streak
  - Embers, film grain, a slow camera push-in and shake during rage
  - Optional dark tower silhouette with lit windows
- **Fast**: the frame is computed with vectorised numpy, and tkinter drawing is optimised (see [How it works](#how-it-works)).
- **Adaptive**: detail can be changed live, and the program lowers it automatically if the frame rate drops.
- **Tiny footprint**: one file, one dependency (numpy).

## Requirements

- Python 3.8 or newer
- [numpy](https://numpy.org/)
- tkinter (included with most Python installs, see [Troubleshooting](#troubleshooting))
- A monospace font (the program picks the first available one of Cascadia Mono, Consolas, Menlo, DejaVu Sans Mono, Liberation Mono, Courier New, Courier)



```bash
python sauron_eye.py
```

### Controls

| Input | Action |
|---|---|
| `Space` | Wake the eye / put it to sleep |
| Mouse | The eye follows your cursor |
| `+` / `-` | Increase / decrease detail (character grid size) |
| `T` | Toggle the dark tower silhouette |
| `Esc` or `Q` | Quit |

## Configuration

Settings are constants at the top of `sauron_eye.py`:

| Constant | Default | Description |
|---|---|---|
| `DETAIL` | `[96, 120, 144, 168, 192]` | Character columns for each detail step |
| `START_LEVEL` | `2` | Index into `DETAIL` used at start-up |
| `TARGET_FPS` | `120` | Upper frame-rate cap (the real rate is limited by Tk) |
| `NPAL` | `18` | Number of colour levels. Fewer is faster, more gives smoother gradients |
| `MIN_LEVEL` | `2` | Colour levels below this are near-black and are not drawn |
| `AUTO_DOWNGRADE_FPS` | `30` | Detail is lowered by one step if the fps falls below this |

The window size adapts automatically: the largest font size whose grid still fits your screen is used.

## How it works

1. **Shader-style rendering with numpy.** For every character cell, the program evaluates a brightness value from analytic functions: an almond-shaped eyelid model, an iris and pupil model, and angular noise-like sine fields for the flames. The whole grid is computed in a few milliseconds with vectorised operations.
2. **Brightness to characters.** Brightness picks a character from a density ramp, with a little jitter in the flames and direction-aware glyphs (`-`, `\`, `|`, `/`) along the iris fibres.
3. **Brightness to colour.** Brightness is quantised into a fire palette (black, deep red, orange, yellow, white-hot).
4. **Layered canvas drawing.** tkinter is the real bottleneck, so each colour level is drawn as a single canvas text item that covers only its own bounding box, with blank line tails trimmed. Items whose text did not change since the last frame are not touched.
5. **A small "director".** A state machine drives eyelid opening, flame intensity, rage, blinking and gaze, so all motion is time-based and independent of the frame rate.

## Performance

Numbers measured on a slow, software-rendered X display (Xvfb) with the eye fully awake:

| Grid | Approx. fps |
|---|---|
| 120 x 56 | ~46 |
| 144 x 66 | ~33-39 |
| 168 x 70 | ~28 |

A normal desktop with a real display is expected to be faster. Rendering a frame takes roughly 4-6 ms; the rest is tkinter drawing time. If it runs slowly on your machine, press `-` or lower `START_LEVEL`.

## Troubleshooting

**`ModuleNotFoundError: No module named 'tkinter'`**
- Debian / Ubuntu: `sudo apt install python3-tk`
- Fedora: `sudo dnf install python3-tkinter`
- macOS (Homebrew Python): `brew install python-tk`
- Windows: re-run the Python installer and make sure *tcl/tk and IDLE* is selected.

**`ModuleNotFoundError: No module named 'numpy'`**
Run `pip install numpy`.

**Characters look misaligned or the picture looks stretched**
Use a true monospace font. Install one of the fonts listed under [Requirements](#requirements).

**Low frame rate**
Press `-` for less detail, or set a smaller `START_LEVEL` and `NPAL` in the file.

## Contributing

Issues and pull requests are welcome. Ideas for future work:

- Fullscreen mode with automatic grid sizing
- Optional sound design
- Export to GIF / MP4
- Additional palettes (for example a cold blue eye)


## Disclaimer

This is an unofficial fan project inspired by the Eye of Sauron from J. R. R. Tolkien's *The Lord of the Rings*. It is not affiliated with or endorsed by the Tolkien Estate or any rights holder.
