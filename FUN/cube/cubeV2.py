#!/usr/bin/env python3
"""
cube.py — A smoothly spinning, shaded ASCII cube for the terminal.

Pure stdlib. No dependencies. Plain terminal white/foreground text only
(no ANSI color) — depth and form come entirely from a lit ASCII shading
ramp and a z-buffer, like a wireframe station tumbling in space.

Usage:
    python3 cube.py                  # default: smooth tumble, shaded solid
    python3 cube.py --speed 1.5      # faster rotation
    python3 cube.py --style wire     # wireframe edges only
    python3 cube.py --size 16        # bigger cube
    python3 cube.py --fps 30         # target frame rate

Controls:
    Ctrl+C to quit.
"""

import argparse
import math
import shutil
import signal
import sys
import time

RESET = "\033[0m"
HIDE_CURSOR = "\033[?25l"
SHOW_CURSOR = "\033[?25h"
CLEAR_HOME = "\033[H"
CLEAR_SCREEN = "\033[2J"

# Monochrome shading ramp, dark -> light. Character density itself carries
# the lighting/depth cue since no color is used.
SHADE_RAMP = " .:-=+*#%@"

# Distinct ramp for cube edges so the silhouette reads clearly against fill.
EDGE_RAMP = "'+#%@"


# ---------------------------------------------------------------------------
# Math: rotation + projection
# ---------------------------------------------------------------------------

def rotate_point(x, y, z, ax, ay, az):
    """Rotate a 3D point around X, then Y, then Z axes (radians)."""
    # Rotate around X
    cosx, sinx = math.cos(ax), math.sin(ax)
    y, z = y * cosx - z * sinx, y * sinx + z * cosx
    # Rotate around Y
    cosy, siny = math.cos(ay), math.sin(ay)
    x, z = x * cosy + z * siny, -x * siny + z * cosy
    # Rotate around Z
    cosz, sinz = math.cos(az), math.sin(az)
    x, y = x * cosz - y * sinz, x * sinz + y * cosz
    return x, y, z


def project(x, y, z, distance, scale, cx, cy):
    """Perspective-project a 3D point to 2D screen space."""
    factor = distance / (distance + z)
    px = x * factor * scale + cx
    py = y * factor * scale * 0.5 + cy  # 0.5 corrects for terminal char aspect ratio
    return px, py, factor


class Face:
    """A quad face of the cube, defined by 4 corner points + a normal + label."""
    __slots__ = ("corners", "normal", "id")

    def __init__(self, corners, normal, face_id):
        self.corners = corners  # list of (x,y,z) in local cube space
        self.normal = normal
        self.id = face_id


def build_cube(half=1.0):
    """Return 6 faces of a cube centered at origin with half-extent `half`."""
    h = half
    verts = {
        "+++": (h, h, h), "++-": (h, h, -h), "+-+": (h, -h, h), "+--": (h, -h, -h),
        "-++": (-h, h, h), "-+-": (-h, h, -h), "--+": (-h, -h, h), "---": (-h, -h, -h),
    }
    faces = [
        Face([verts["+++"], verts["++-"], verts["-+-"], verts["-++"]], (0, 1, 0), "top"),
        Face([verts["+-+"], verts["+--"], verts["---"], verts["--+"]], (0, -1, 0), "bottom"),
        Face([verts["+++"], verts["++-"], verts["+--"], verts["+-+"]], (1, 0, 0), "right"),
        Face([verts["-++"], verts["-+-"], verts["---"], verts["--+"]], (-1, 0, 0), "left"),
        Face([verts["+++"], verts["-++"], verts["--+"], verts["+-+"]], (0, 0, 1), "front"),
        Face([verts["++-"], verts["-+-"], verts["---"], verts["+--"]], (0, 0, -1), "back"),
    ]
    return faces


def sample_face_points(face, density):
    """Generate a grid of sample points across a face's surface (for fill rendering)."""
    (x0, y0, z0), (x1, y1, z1), (x2, y2, z2), (x3, y3, z3) = face.corners
    pts = []
    for i in range(density + 1):
        u = i / density
        for j in range(density + 1):
            v = j / density
            # bilinear interpolation across the quad
            top_x = x0 + (x1 - x0) * u
            top_y = y0 + (y1 - y0) * u
            top_z = z0 + (z1 - z0) * u
            bot_x = x3 + (x2 - x3) * u
            bot_y = y3 + (y2 - y3) * u
            bot_z = z3 + (z2 - z3) * u
            px = top_x + (bot_x - top_x) * v
            py = top_y + (bot_y - top_y) * v
            pz = top_z + (bot_z - top_z) * v
            pts.append((px, py, pz))
    return pts


# ---------------------------------------------------------------------------
# Renderer
# ---------------------------------------------------------------------------

class CubeRenderer:
    def __init__(self, args):
        self.args = args
        self.faces = build_cube(half=1.0)
        self.density = max(6, args.size // 2)
        self.angle_x = 0.3
        self.angle_y = 0.4
        self.angle_z = 0.0
        # three incommensurate speeds so the tumble never repeats/loops
        # and always reveals a different facet — true free-tumble, not a
        # single-axis spin.
        self.speed_x = 0.47 * args.speed
        self.speed_y = 0.83 * args.speed
        self.speed_z = 0.31 * args.speed
        self.start_time = time.time()
        self.stars = self._make_starfield()

    def _make_starfield(self):
        import random
        rnd = random.Random(42)
        return [(rnd.random(), rnd.random(), rnd.random() * 0.6 + 0.2) for _ in range(60)]

    def term_size(self):
        cols, rows = shutil.get_terminal_size(fallback=(80, 24))
        return cols, rows

    def render_frame(self, dt):
        self.angle_x += self.speed_x * dt
        self.angle_y += self.speed_y * dt
        self.angle_z += self.speed_z * dt

        cols, rows = self.term_size()
        width = min(cols - 2, 60)
        height = min(rows - 4, 24)
        cx, cy = width / 2, height / 2
        scale = min(width, height * 2) * 0.22 * (self.args.size / 16.0)
        distance = 4.0

        # z-buffer style screen grid: char + depth. No color tracked at all —
        # plain terminal foreground only. Depth/shape read purely from which
        # ASCII character (density) is placed at each cell.
        screen = [[" " for _ in range(width)] for _ in range(height)]
        depth = [[float("-inf") for _ in range(width)] for _ in range(height)]

        # background starfield (faint, twinkling) purely for spatial context
        t = time.time() - self.start_time
        for (sx, sy, tw) in self.stars:
            twinkle = (math.sin(t * tw * 3 + sx * 10) + 1) / 2
            if twinkle > 0.75:
                col = int(sx * width)
                row = int(sy * height)
                if 0 <= col < width and 0 <= row < height:
                    screen[row][col] = "."
                    depth[row][col] = -999

        # Light direction fixed in world space, gives each face a distinct
        # brightness so the cube reads as a solid tumbling object rather
        # than flat panels.
        light = (0.45, 0.65, -1.0)
        llen = math.sqrt(sum(c * c for c in light))
        light = tuple(c / llen for c in light)

        # Sort faces back-to-front by rotated-normal Z as a cheap painter's
        # pass in addition to the z-buffer — helps wireframe mode layer
        # correctly since it doesn't densely fill the z-buffer.
        face_data = []
        for face in self.faces:
            nx, ny, nz = face.normal
            rn = rotate_point(nx, ny, nz, self.angle_x, self.angle_y, self.angle_z)
            face_data.append((face, rn))
        face_data.sort(key=lambda fd: fd[1][2])

        for face, (rnx, rny, rnz) in face_data:
            # backface culling: only draw faces pointing toward the viewer
            if rnz <= 0.05:
                continue

            brightness = max(0.0, rnx * -light[0] + rny * -light[1] + rnz * -light[2])

            if self.args.style == "wire":
                corners2d = []
                for (x, y, z) in face.corners:
                    rx, ry, rz = rotate_point(x, y, z, self.angle_x, self.angle_y, self.angle_z)
                    px, py, _ = project(rx, ry, rz, distance, scale, cx, cy)
                    corners2d.append((px, py, rz))
                ramp_i = min(len(EDGE_RAMP) - 1, int(brightness * (len(EDGE_RAMP) - 1)))
                edge_char = EDGE_RAMP[max(0, ramp_i)]
                for i in range(4):
                    x0, y0, z0 = corners2d[i]
                    x1, y1, z1 = corners2d[(i + 1) % 4]
                    steps = int(max(abs(x1 - x0), abs(y1 - y0)) * 1.5) + 1
                    for s in range(steps + 1):
                        tt = s / steps
                        lx = x0 + (x1 - x0) * tt
                        ly = y0 + (y1 - y0) * tt
                        lz = z0 + (z1 - z0) * tt
                        col = int(lx)
                        row = int(ly)
                        if 0 <= col < width and 0 <= row < height:
                            if lz > depth[row][col]:
                                depth[row][col] = lz
                                screen[row][col] = edge_char
            else:
                pts = sample_face_points(face, self.density)
                fill_i = min(len(SHADE_RAMP) - 1, int(brightness * (len(SHADE_RAMP) - 1)))
                fill_char = SHADE_RAMP[max(1, fill_i)]
                for (x, y, z) in pts:
                    rx, ry, rz = rotate_point(x, y, z, self.angle_x, self.angle_y, self.angle_z)
                    px, py, _ = project(rx, ry, rz, distance, scale, cx, cy)
                    col = int(px)
                    row = int(py)
                    if 0 <= col < width and 0 <= row < height:
                        if rz > depth[row][col]:
                            depth[row][col] = rz
                            screen[row][col] = fill_char

                # crisp edge outline on top of the shaded fill, so silhouette
                # and face boundaries stay readable at any brightness level
                corners2d = []
                for (x, y, z) in face.corners:
                    rx, ry, rz = rotate_point(x, y, z, self.angle_x, self.angle_y, self.angle_z)
                    px, py, _ = project(rx, ry, rz, distance, scale, cx, cy)
                    corners2d.append((px, py, rz))
                for i in range(4):
                    x0, y0, z0 = corners2d[i]
                    x1, y1, z1 = corners2d[(i + 1) % 4]
                    steps = int(max(abs(x1 - x0), abs(y1 - y0)) * 1.5) + 1
                    for s in range(steps + 1):
                        tt = s / steps
                        lx = x0 + (x1 - x0) * tt
                        ly = y0 + (y1 - y0) * tt
                        lz = z0 + (z1 - z0) * tt + 0.001  # nudge above fill in depth
                        col = int(lx)
                        row = int(ly)
                        if 0 <= col < width and 0 <= row < height:
                            if lz >= depth[row][col]:
                                depth[row][col] = lz
                                screen[row][col] = "#"

        return self._compose(screen, width, height)

    def _compose(self, screen, width, height):
        lines = []
        for row in range(height):
            lines.append("".join(screen[row]))
        return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="A smoothly rotating, shaded ASCII cube — like a station tumbling in space."
    )
    parser.add_argument("--speed", type=float, default=1.0, help="Rotation speed multiplier (default 1.0)")
    parser.add_argument("--style", choices=["solid", "wire"], default="solid", help="Render style")
    parser.add_argument("--size", type=int, default=12, help="Cube size / detail (default 12)")
    parser.add_argument("--fps", type=int, default=30, help="Target frames per second (default 30)")
    args = parser.parse_args()

    renderer = CubeRenderer(args)

    def handle_sigint(sig, frame):
        sys.stdout.write(SHOW_CURSOR + RESET + "\n")
        sys.stdout.flush()
        sys.exit(0)

    signal.signal(signal.SIGINT, handle_sigint)

    frame_time = 1.0 / max(1, args.fps)
    sys.stdout.write(HIDE_CURSOR + CLEAR_SCREEN)
    try:
        last = time.time()
        while True:
            now = time.time()
            dt = now - last
            last = now
            frame = renderer.render_frame(dt)
            sys.stdout.write(CLEAR_HOME + frame)
            sys.stdout.flush()
            elapsed = time.time() - now
            sleep_left = frame_time - elapsed
            if sleep_left > 0:
                time.sleep(sleep_left)
    except KeyboardInterrupt:
        pass
    finally:
        sys.stdout.write(SHOW_CURSOR + RESET + "\n")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
