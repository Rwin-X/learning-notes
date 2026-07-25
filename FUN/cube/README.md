# cube.py

A smoothly rotating, shaded ASCII cube for the terminal — tumbles on
three axes at once like a small object adrift in space. Pure Python
stdlib, no dependencies.

## Run

```bash
python3 cube.py
```

Press `Ctrl+C` to quit.

## Options

| Flag        | Values                          | Default | Description                          |
|-------------|----------------------------------|---------|---------------------------------------|
| `--speed`   | float                            | `1.0`   | Rotation speed multiplier             |
| `--style`   | `solid`, `wire`                  | `solid` | Shaded surface fill or wireframe edges|
| `--color`   | `cyan`, `green`, `amber`, `mono` | `cyan`  | Color palette                         |
| `--size`    | int                              | `16`    | Cube size / surface detail            |
| `--fps`     | int                              | `30`    | Target frame rate                     |

## Examples

```bash
python3 cube.py --style wire --color green
python3 cube.py --speed 2 --size 22
python3 cube.py --color amber --fps 24
```

## How it works

Each frame, every visible face is rotated with standard X/Y/Z rotation
matrices, then perspective-projected to 2D. A simple z-buffer resolves
which surface point is nearest the viewer per character cell, and a
fixed light direction drives per-face lambertian shading — mapped to
an ANSI color ramp so the faces read as solid, lit surfaces rather
than a flat wireframe. Backface culling drops faces pointing away from
the viewer. A faint twinkling starfield sits behind it for depth.

Resize your terminal any time — the render adapts to the current
terminal dimensions each frame.
