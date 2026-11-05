#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
THE FELLOWSHIP AND THE EYE - a cinematic ASCII scene (numpy + tkinter)

Nine travellers climb a snowy mountain pass while the Eye of Sauron watches
them from the sky. Everything is generated procedurally and drawn with text
characters: the eye, the flames, the parallax mountains, the blizzard and the
nine silhouettes with their own walk cycles.

Install:  pip install numpy          (tkinter ships with Python)
Run:      python fellowship_eye.py

Controls
  SPACE      wake / put the eye to sleep
  mouse      the eye follows your cursor (otherwise it watches the company)
  + / -      more / less detail (character grid size)
  S          toggle the blizzard
  ESC / Q    quit

If the frame rate drops below ~30 fps the program lowers the detail by one
step automatically.

Unofficial fan project inspired by J. R. R. Tolkien's "The Lord of the Rings".
"""
import math
import random
import sys
import time

try:
    import numpy as np
except ImportError:
    sys.exit("This program needs numpy:  pip install numpy")
import tkinter as tk
import tkinter.font as tkfont

# ----------------------------------------------------------------------------
# Settings
# ----------------------------------------------------------------------------
DETAIL = [96, 120, 144, 168, 192]   # character columns for each detail step
START_LEVEL = 2                     # index into DETAIL used at start-up
TARGET_FPS = 120                    # upper cap; the real rate is limited by Tk
NPAL = 18                           # number of colour levels (= canvas layers)
MIN_LEVEL = 2                       # levels below this are near-black: not drawn
AUTO_DOWNGRADE_FPS = 30             # lower the detail when fps falls below this

EYE_CX, EYE_CY, EYE_SCALE = 0.0, -0.40, 0.70   # where the eye hangs in the sky

NP1 = NPAL - 1
RAMP = " .'`,:;~-+=*xoX%#&@"        # characters ordered by visual density
LM = len(RAMP) - 1
RAMPC = np.frombuffer(RAMP.encode(), np.uint8)
TIPC = np.frombuffer(b"^'\"~", np.uint8)    # glyphs for flame tips
DIRC = np.frombuffer(b"-\\|/", np.uint8)    # glyphs for iris fibre direction
f32 = np.float32
sin, cos, exp = math.sin, math.cos, math.exp
PI = math.pi

# The company, listed left to right; they walk to the right, Gandalf leads.
# s = height in screen units, bw = body width multiplier, off = walk phase offset.
FELLOWSHIP = [
    dict(name="pippin",  kind="hobbit",  x=-0.90, s=0.285, bw=1.25, pack=0.70, off=0.0),
    dict(name="merry",   kind="hobbit",  x=-0.76, s=0.295, bw=1.25, pack=0.90, off=1.2),
    dict(name="sam",     kind="hobbit",  x=-0.61, s=0.305, bw=1.35, pack=1.50, off=2.1),
    dict(name="frodo",   kind="hobbit",  x=-0.46, s=0.290, bw=1.25, pack=0.55, off=3.0, hood=True),
    dict(name="gimli",   kind="gimli",   x=-0.29, s=0.355, bw=1.70, off=0.6),
    dict(name="boromir", kind="boromir", x=-0.07, s=0.490, bw=1.15, off=2.4),
    dict(name="legolas", kind="legolas", x=0.14,  s=0.505, bw=0.80, off=1.7),
    dict(name="aragorn", kind="aragorn", x=0.36,  s=0.505, bw=1.00, off=0.3),
    dict(name="gandalf", kind="gandalf", x=0.60,  s=0.540, bw=1.05, off=2.9),
]


def build_palette(n=NPAL):
    """Black -> deep red -> orange -> yellow -> white-hot gradient."""
    stops = [(0.00, (0, 0, 0)), (0.08, (30, 0, 0)), (0.22, (100, 6, 0)),
             (0.40, (185, 32, 0)), (0.56, (236, 84, 0)), (0.72, (255, 150, 12)),
             (0.87, (255, 216, 96)), (1.00, (255, 250, 212))]
    pal = []
    for k in range(n):
        x = k / (n - 1)
        for j in range(len(stops) - 1):
            x0, c0 = stops[j]
            x1, c1 = stops[j + 1]
            if x <= x1:
                f = (x - x0) / (x1 - x0)
                pal.append(tuple(int(c0[m] + (c1[m] - c0[m]) * f) for m in range(3)))
                break
    return pal


PAL = build_palette()


def smooth(x):
    """Smootherstep easing, clamped to [0, 1]."""
    x = 0.0 if x < 0 else (1.0 if x > 1 else x)
    return x * x * x * (x * (6 * x - 15) + 10)


def blur(a):
    """Cheap bloom: two separable blur passes."""
    for _ in range(2):
        p = a.copy()
        p[:, 1:] += 0.6 * a[:, :-1]
        p[:, :-1] += 0.6 * a[:, 1:]
        q = p.copy()
        q[1:] += 0.5 * p[:-1]
        q[:-1] += 0.5 * p[1:]
        a = q * 0.23
    return a


# ---- small geometry helpers used by the silhouettes (all vectorised) ----
def rad_c(u, v):
    """Distance from the eye centre in eye space."""
    return np.hypot(u, v)


def tri(x):
    """Triangle wave in [0, 1]; gives sharp, angular mountain crests."""
    return np.abs(np.mod(x, 2.0) - 1.0)


def ground_y(u, s):
    """Height (screen v) of the path at horizontal position u; s = scroll offset."""
    return 0.74 - 0.22 * u + 0.012 * np.sin(5.0 * (u + s)) + 0.006 * np.sin(13.0 * (u + s) + 1.0)


def seg_mask(U, V, x0, y0, x1, y1, r):
    """Thick line segment (staff, limb, sword ...). Minimum thickness ~1 cell."""
    r = max(r, 0.008)
    dx, dy = x1 - x0, y1 - y0
    l2 = dx * dx + dy * dy + 1e-9
    t = np.clip(((U - x0) * dx + (V - y0) * dy) / l2, 0.0, 1.0)
    return (U - (x0 + t * dx)) ** 2 + (V - (y0 + t * dy)) ** 2 < r * r


def cone_mask(U, V, cx, ya, yb, wa, wb, shift=0.0):
    """Tapered body from height ya (top) to yb (bottom); shift bends the hem sideways."""
    f = (V - ya) / (yb - ya)
    w = wa + (wb - wa) * f
    return (f >= 0) & (f <= 1) & (np.abs(U - cx - shift * f * f) < np.maximum(w, 0.007))


def ell_mask(U, V, cx, cy, rx, ry):
    rx, ry = max(rx, 0.008), max(ry, 0.008)
    return ((U - cx) / rx) ** 2 + ((V - cy) / ry) ** 2 < 1.0


# ----------------------------------------------------------------------------
# Renderer (numpy)
# ----------------------------------------------------------------------------
class Eye:
    A = 0.76                         # half-width of the almond-shaped eye (eye space)
    IRX, IRY = 1 / 0.36, 1 / 0.41    # inverse iris radii (x, y)

    def __init__(self, cols, cw, ch):
        self.cols, self.cw, self.ch = cols, cw, ch
        R = self.rows = max(24, round(cols * cw / ch))   # keep the picture square
        self.W, self.H = cols * cw, R * ch
        half = self.half = self.W / 2.0
        # Normalised screen coordinates: u, v in about [-1, 1], y pointing down.
        self.du = 2.0 / cols
        self.dv = ch / half
        self.v0 = (0.5 * ch - self.H / 2) / half
        xs = (((np.arange(cols) + 0.5) * cw - self.W / 2) / half).astype(f32)
        ys = (((np.arange(R) + 0.5) * ch - self.H / 2) / half).astype(f32)
        self.xs = xs
        self.U0 = np.ascontiguousarray(np.broadcast_to(xs, (R, cols)))
        self.V0 = np.ascontiguousarray(np.broadcast_to(ys[:, None], (R, cols)))
        self.vig = np.clip(1.20 - 0.62 * (self.U0 ** 2 + self.V0 ** 2), 0, 1).astype(f32)
        # Light that the eye throws on the landscape: strongest right below it.
        self.light = (0.35 + 0.65 * np.exp(-((xs - EYE_CX) / 0.9) ** 2)).astype(f32)[None, :]
        self.rng = np.random.default_rng()
        self.E = np.zeros((0, 7), f32)       # embers: x, y, vx, vy, age, life, phase
        self.acc = 0.0
        n = int(190 * cols / 144)            # blizzard flakes: x, y, vx, vy, phase, size
        rng = self.rng
        self.S = np.stack([rng.random(n) * 2 - 1, rng.random(n) * 2 - 1,
                           -(0.25 + 0.25 * rng.random(n)), 0.06 + 0.10 * rng.random(n),
                           rng.random(n) * 6.28, rng.random(n)], axis=1).astype(f32)
        self.walk = 0.0                      # walk-cycle phase
        self.scroll = 0.0                    # how far the world has scrolled

    # ---- embers rising from the eye ----
    def _embers(self, dt, fire, rage):
        self.acc += 90.0 * fire * (1 + rage) * dt
        k = int(self.acc)
        self.acc -= k
        E, rng = self.E, self.rng
        if k > 0:
            ang = rng.random(k) * 6.2832
            rr = 0.25 + rng.random(k) * 0.55
            new = np.empty((k, 7), f32)
            new[:, 0] = EYE_CX + np.cos(ang) * rr * 0.95 * EYE_SCALE
            new[:, 1] = EYE_CY + np.sin(ang) * rr * 0.7 * EYE_SCALE
            new[:, 2] = (rng.random(k) - 0.5) * 0.08
            new[:, 3] = -(0.10 + 0.25 * rng.random(k))
            new[:, 4] = 0
            new[:, 5] = 1.8 + 3.0 * rng.random(k)
            new[:, 6] = rng.random(k) * 6.28
            E = np.vstack([E, new])
        if len(E):
            E[:, 4] += dt
            E[:, 0] += E[:, 2] * dt + 0.03 * np.sin(E[:, 4] * 3 + E[:, 6]) * dt
            E[:, 1] += E[:, 3] * dt
            E = E[(E[:, 4] < E[:, 5]) & (np.abs(E[:, 0]) < 1) & (np.abs(E[:, 1]) < 1)]
        self.E = E

    # ---- blizzard ----
    def _snow(self, dt, gust):
        S = self.S
        S[:, 0] += S[:, 2] * (0.5 + gust) * dt + 0.02 * np.sin(S[:, 4] + self.walk * 0.7) * dt
        S[:, 1] += S[:, 3] * (0.7 + 0.5 * gust) * dt
        S[S[:, 0] < -1.0, 0] += 2.0
        S[S[:, 1] > 1.0, 1] -= 2.0

    # ---- mountain layer: faceted rock, each face lit by the eye (Lambert), snowy crest ----
    def _mountain(self, I, ridge, fire, k_base, k_face, k_crest, sx):
        xs = self.xs.astype(np.float64)
        r = ridge.astype(np.float64)
        slope = np.gradient(r, xs)                                   # d(ridge)/du
        lx_, ly_ = EYE_CX - xs, r - EYE_CY                            # surface -> eye
        lam = np.clip((slope * lx_ + ly_) / (np.sqrt(1 + slope * slope) * np.hypot(lx_, ly_) + 1e-6), 0, 1)
        lam = lam.astype(f32)[None, :]
        depth = self.V0 - ridge[None, :]
        m = depth > 0
        dp = np.maximum(depth, 0)
        fade = 0.55 + 0.45 * np.exp(-dp * 3.0)                       # darker toward the bottom
        # rock strata and snow streaks running along the slope
        tex = 0.78 + 0.22 * np.sin(dp * 85 + (self.U0 + sx) * 31 * np.sign(slope.astype(f32))[None, :]) \
            * np.sin((self.U0 + sx) * 47 + dp * 20)
        Il = fire * self.light * ((k_base + k_face * lam) * fade * tex + k_crest * np.exp(-dp * 80.0))
        return np.where(m, Il, I), m

    def _ground(self, I, ridge, fire, sx):
        """The path: smooth snow drifts, bright crest line where the travellers walk."""
        depth = self.V0 - ridge[None, :]
        m = depth > 0
        dp = np.maximum(depth, 0)
        bands = 0.5 + 0.5 * np.sin(dp * 120 + 2.5 * np.sin((self.U0 + sx) * 7 + 1.0))
        fade = 0.45 + 0.55 * np.exp(-dp * 2.5)
        Il = fire * self.light * ((0.07 + 0.10 * bands) * fade + 0.95 * np.exp(-dp * 95.0))
        return np.where(m, Il, I), m

    # ---- one traveller as a silhouette mask ----
    def _figure(self, sp, gs, ph, sway, fm):
        R, C = self.rows, self.cols
        s, bw, x0, kind = sp["s"], sp["bw"], sp["x"], sp["kind"]
        yg = float(ground_y(x0, gs))                       # where the feet touch the path
        hw = 0.46 * s * max(bw, 1.0) + 0.06
        c0 = max(0, int((x0 - hw + 1) / self.du - 0.5))
        c1 = min(C, int((x0 + hw + 1) / self.du - 0.5) + 2)
        r0 = max(0, int((yg - 1.30 * s - self.v0) / self.dv - 0.5))
        r1 = min(R, int((yg + 0.04 - self.v0) / self.dv - 0.5) + 2)
        if c1 <= c0 or r1 <= r0:
            return
        U, V = self.U0[r0:r1, c0:c1], self.V0[r0:r1, c0:c1]
        m = np.zeros(U.shape, bool)

        yb = yg - 0.010 * s * abs(sin(ph))                 # body base bobs while walking
        hip, sho, hd = yb - 0.30 * s, yb - 0.66 * s, yb - 0.80 * s
        lean = 0.012 * s * sin(ph * 2)
        sw = sway * s                                      # wind drags cloaks to the left
        stride = 0.13 * s * (0.8 if kind == "hobbit" else 1.0)

        # legs
        for sg in (1.0, -1.0):
            fx = x0 + sg * stride * sin(ph)
            lift = 0.07 * s * max(0.0, sg * cos(ph))
            m |= seg_mask(U, V, x0, hip, fx, yg - lift, 0.045 * s * min(bw, 1.2))
        # arms swing opposite to the legs
        for sg in (1.0, -1.0):
            hx = x0 - sg * 0.09 * s * sin(ph)
            m |= seg_mask(U, V, x0 + sg * 0.05 * s * bw, sho + 0.03 * s, hx, yb - 0.40 * s, 0.032 * s)

        if kind == "hobbit":
            rh = 0.095 * s
            m |= cone_mask(U, V, x0 + lean, sho, yb - 0.08 * s, 0.075 * s * bw, 0.135 * s * bw, sw * 0.5)
            m |= ell_mask(U, V, x0 + lean * 1.4, hd, rh, rh * 1.05)
            pk = sp.get("pack", 0.8)
            m |= ell_mask(U, V, x0 - 0.14 * s * bw, sho + 0.14 * s, 0.11 * s * pk, 0.14 * s * pk)  # backpack
            if sp["name"] == "sam":                        # cooking pots on top of the pack
                m |= ell_mask(U, V, x0 - 0.15 * s, sho - 0.07 * s, 0.05 * s, 0.05 * s)
            if sp.get("hood"):                             # pointed hood
                m |= cone_mask(U, V, x0 + lean, hd - 0.15 * s, hd + 0.02 * s, 0.0, 0.10 * s, sw * 0.8)

        elif kind == "gimli":
            rh = 0.085 * s
            m |= cone_mask(U, V, x0 + lean, sho, yb - 0.06 * s, 0.12 * s, 0.17 * s, sw * 0.4)
            m |= ell_mask(U, V, x0 + lean * 1.4, hd, rh, rh)
            m |= ell_mask(U, V, x0 + lean * 1.4, hd - 0.03 * s, rh * 1.18, rh * 0.85)             # helm
            m |= cone_mask(U, V, x0 + lean, hd, hd + 0.34 * s, 0.10 * s, 0.015 * s, sw * 0.5)     # beard
            m |= seg_mask(U, V, x0 + 0.10 * s, sho + 0.05 * s, x0 + 0.25 * s, sho - 0.32 * s, 0.020 * s)
            m |= ell_mask(U, V, x0 + 0.27 * s, sho - 0.34 * s, 0.07 * s, 0.10 * s)               # axe head

        elif kind == "gandalf":
            m |= cone_mask(U, V, x0 + lean, sho, yg - 0.03 * s, 0.075 * s * bw, 0.145 * s * bw, sw * 0.7)
            m |= ell_mask(U, V, x0 + lean * 1.4, hd, 0.07 * s, 0.075 * s)
            m |= cone_mask(U, V, x0 + lean, hd + 0.02 * s, hd + 0.32 * s, 0.05 * s, 0.012 * s, sw * 0.9)   # beard
            m |= ell_mask(U, V, x0 + lean * 1.4, hd - 0.055 * s, 0.135 * s, 0.020 * s)                      # hat brim
            m |= cone_mask(U, V, x0 + lean * 1.4, hd - 0.38 * s, hd - 0.055 * s, 0.0, 0.085 * s, sw * 1.2)  # hat
            sx = x0 + 0.19 * s
            m |= seg_mask(U, V, sx, yg + 0.01, sx - 0.02 * s, yb - 1.02 * s, 0.014 * s)                     # staff
            m |= ell_mask(U, V, sx - 0.02 * s, yb - 1.04 * s, 0.028 * s, 0.028 * s)

        elif kind == "aragorn":
            m |= cone_mask(U, V, x0 + lean, sho, yb - 0.10 * s, 0.08 * s, 0.155 * s, sw * 0.9)
            m |= ell_mask(U, V, x0 + lean * 1.4, hd, 0.075 * s, 0.08 * s)
            m |= cone_mask(U, V, x0 + lean - 0.02 * s, hd - 0.01 * s, hd + 0.17 * s, 0.05 * s, 0.03 * s, sw)  # hair
            m |= seg_mask(U, V, x0 - 0.05 * s, hip, x0 - 0.20 * s, hip + 0.12 * s, 0.013 * s)                 # sword

        elif kind == "boromir":
            m |= cone_mask(U, V, x0 + lean, sho, yb - 0.08 * s, 0.095 * s * bw, 0.15 * s * bw, sw * 0.7)
            m |= ell_mask(U, V, x0 + lean * 1.4, hd, 0.078 * s, 0.082 * s)
            m |= ell_mask(U, V, x0 - 0.15 * s * bw, sho + 0.12 * s, 0.13 * s, 0.13 * s)                       # round shield
            m |= seg_mask(U, V, x0 - 0.04 * s, hip, x0 - 0.18 * s, hip + 0.12 * s, 0.014 * s)                 # sword

        elif kind == "legolas":
            m |= cone_mask(U, V, x0 + lean, sho, yb - 0.10 * s, 0.07 * s * bw, 0.115 * s * bw, sw * 0.8)
            m |= ell_mask(U, V, x0 + lean * 1.4, hd, 0.07 * s, 0.078 * s)
            m |= cone_mask(U, V, x0 + lean - 0.02 * s, hd - 0.01 * s, hd + 0.34 * s, 0.05 * s, 0.025 * s, sw * 1.4)  # long hair
            bx, by, br = x0 + 0.10 * s, yb - 0.55 * s, 0.50 * s                                                # bow (arc on the back)
            d = np.hypot(U - bx, V - by)
            m |= (np.abs(d - br) < 0.010) & (U < bx - 0.30 * br)
            m |= seg_mask(U, V, bx - 0.30 * br, by - 0.954 * br, bx - 0.30 * br, by + 0.954 * br, 0.006)       # bowstring
            m |= seg_mask(U, V, x0 - 0.08 * s, sho + 0.10 * s, x0 - 0.03 * s, sho - 0.14 * s, 0.030 * s)       # quiver

        fm[r0:r1, c0:c1] |= m

    # ---- one frame ----
    def render(self, t, d, snow=True):
        """Return a list (one entry per colour level) of (text, col, row) or None."""
        R, C = self.rows, self.cols
        rng = self.rng
        A = self.A
        dt = d.dt
        opn = d.open * d.blink                  # eyelid opening including blinks
        rage, fire = d.rage, d.fire
        lx, ly = d.gx, d.gy                     # gaze offset
        gust = d.gust

        # World motion: the company walks, the landscape scrolls past them.
        speed = 1.0 + 0.6 * rage
        self.walk += dt * 2 * PI * 1.05 * speed
        self.scroll += dt * 0.12 * speed

        # Camera: slow push-in as the eye opens, plus shake during rage.
        z = 1.0 + 0.03 * min(d.open, 1.2) + 0.03 * rage + 0.010 * sin(t * 0.23)
        jx = jy = 0.0
        if d.shake > 0.02:
            jx = random.uniform(-1, 1) * 0.012 * d.shake
            jy = random.uniform(-1, 1) * 0.012 * d.shake
        # Eye space: the eye lives in its own coordinate system, scaled and moved up.
        k = 1.0 / (z * EYE_SCALE)
        u = (self.U0 - EYE_CX) * k + jx
        v = (self.V0 - EYE_CY) * k + jy
        th = np.arctan2(v, u)
        g = np.hypot(u * (1 / 1.25), v * (1 / 1.15))    # elliptical flame metric

        up_h, lo_h = 0.46 * opn, 0.36 * opn             # upper / lower lid heights
        kc = 0.35 * opn
        rim_amp = 0.55 + 0.45 * min(1.0, opn * 3.0)     # lid rim brightness
        pw = (0.036 + 0.008 * sin(t * 1.9) + 0.004 * sin(t * 5.3)) * (1 - 0.45 * rage)  # pupil width
        fl = 0.60 * fire * (0.4 + 0.6 * min(1.0, opn * 2.0))                            # lens streak
        gl = (1.0 + 0.25 * rage) * (1.0 + 0.04 * sin(t * 8.3))                          # inner glow
        fire_k = 0.45 + 0.65 * fire
        reach_k = 0.55 + 0.45 * fire

        # ---- flames: several layers of angular lobes ----
        w1 = np.sin(th * 11 + 2.0 * np.sin(g * 7 - t * 3.2) - t * 1.7)
        w2 = np.sin(th * 17 - g * 9 + t * 2.6)
        w3 = np.sin(th * 29 + g * 13 - t * 4.1 + 1.7 * np.sin(th * 5 + t * 0.8))
        lobe = (0.5 + 0.5 * w1) ** 2
        reach = (0.50 + 0.80 * lobe * (0.80 + 0.20 * w2) + 0.10 * lobe * w3) * reach_k
        reach = reach * np.where(v < 0, 1 - 0.30 * v, 1.0)         # flames rise higher upward
        rg = reach - g
        F = np.where(rg > 0, np.clip(rg / reach, 0, 1) ** 0.9 * 0.95, 0.0)
        F = F * (0.80 + 0.20 * np.sin(v * 22 - t * 7 + 3 * np.sin(u * 11 + t)))   # licking motion
        I_out = F * fire_k + (0.38 * np.exp(-3.0 * g * g) + 0.08 * np.exp(-1.3 * g)) * fire
        # volumetric god rays
        rad = np.hypot(u, v)
        rays = (0.5 + 0.5 * np.sin(th * 9 + t * 0.35 + 2 * np.sin(th * 3 - t * 0.2))) ** 4
        I_out = I_out + rays * np.exp(-1.6 * rad) * 0.14 * fire * (0.3 + 0.7 * min(1.0, opn))
        # swirling storm clouds lit from the eye, and a glowing horizon haze
        swirl = 0.5 + 0.5 * np.sin(3 * th + 5.5 * rad_c(u, v) - t * 0.35 + 1.6 * np.sin(5 * th + 3 * rad_c(u, v) + t * 0.2))
        I_out = I_out + 0.20 * fire * swirl ** 3 * np.exp(-1.1 * rad_c(u, v)) * (0.4 + 0.6 * min(1.0, opn + 0.3))
        I_out = I_out + 0.20 * fire * np.exp(-((self.V0 - 0.40) / 0.20) ** 2) * self.light

        # ---- eyelid geometry (almond shape) ----
        x = u * (1 / A)
        t1 = np.clip(1 - x * x, 0, None)
        in_u = np.abs(u) < A
        s = np.where(in_u, t1 ** 0.85, 0.0)                         # lid profile
        sl = np.where(in_u, np.abs(0.85 * np.maximum(t1, 1e-3) ** -0.15 * 2 * x / A), 0.0)  # its slope
        du = v + up_h * s                                           # distance below the upper lid
        dl = lo_h * s - v                                           # distance above the lower lid
        inside = in_u & (du > 0) & (dl > 0)
        corr = 1.0 / (1.0 + kc * sl)                                # slope-corrected distance
        m = np.minimum(du, dl) * corr                               # depth inside the eye
        dd = np.where(in_u, np.where(du < 0, -du, -dl) * corr, np.hypot(np.abs(u) - A, v))
        dd = np.maximum(dd, 0)                                      # distance outside the eye

        # Outside: dark socket shadow, bright lid rim, lava cracks on the lids.
        tt = np.clip((dd - 0.02) * 11.0, 0, 1)
        I_out = I_out * (tt * tt * (3 - 2 * tt))
        lava = np.clip(np.sin(u * 37 + 3 * np.sin(v * 23 + t * 0.3)) * np.sin(v * 41 - 2 * np.sin(u * 17)), 0, 1) ** 3
        I_out = I_out + 0.30 * lava * np.exp(-dd * 9.0) * (dd > 0.03) * (0.5 + 0.5 * fire)
        bgf = np.exp(-np.abs(v) * 14.0) * np.exp(-np.abs(u) * 0.7)  # horizontal lens streak
        I_out = I_out + rim_amp * np.exp(-dd * dd * 1100.0) + bgf * fl

        # ---- inside the eye ----
        dx = u - lx
        dy = v - ly
        q = np.hypot(dx * self.IRX, dy * self.IRY)                  # 0 at pupil, 1 at iris edge
        phi = np.arctan2(dy, dx)
        fib = 0.5 + 0.5 * np.sin(phi * 34 + 2.5 * np.sin(q * 8 - t * 1.1))    # coarse fibres
        fib2 = 0.5 + 0.5 * np.sin(phi * 91 + 4.0 * np.sin(q * 17 + t * 0.7))  # fine fibres
        crypt = np.sin(phi * 7 + q * 12) * np.sin(phi * 5 - q * 9 + t * 0.5)  # dark blotches
        Ii = (0.80 - 0.40 * q + 0.20 * (fib - 0.5) + 0.10 * (fib2 - 0.5)
              + 0.12 * np.exp(-((q - 0.45) / 0.05) ** 2) - 0.10 * np.clip(crypt - 0.3, 0, None))
        Ii = Ii * np.where(q > 0.84, 0.62 + 0.38 * (1 - q) * 6.25, 1.0)       # limbal ring
        # Slit pupil with pointed tips.
        ph = 0.37
        ty = np.clip(1 - (dy / ph) ** 2, 0, 1)
        pn = np.abs(dx) / (pw * np.maximum(ty, 1e-3) ** 0.75)
        pup = (np.abs(dy) < ph) & (pn < 1)
        glow = np.clip(1 - (pn - 1) / 2.2, 0, 1) * (np.abs(dy) < ph * 1.03)
        Ii = Ii + 0.65 * glow * (~pup)                                        # hot rim around the slit
        iris = q < 1.0
        # Fiery sclera: veins plus a halo around the iris.
        vein = (0.5 + 0.5 * np.sin(phi * 23 + 3 * np.sin(q * 20))) ** 8 * 0.18
        scl = (0.16 + 0.26 * np.exp(-(u * u * 2.0 + v * v * 10.0)) + vein
               + 0.05 * np.sin(u * 23 + t * 1.3) * np.sin(v * 31 - t * 0.9))
        halo = 0.30 * np.exp(-(((q - 1) * 3) ** 2) * 2)
        I_in = np.where(iris, np.maximum(scl, Ii), scl + halo)
        spec = np.exp(-(((dx + 0.11) * 20) ** 2 + ((dy + 0.15) * 33) ** 2))   # specular glint
        I_in = I_in + 0.7 * spec * iris
        I_in = np.where(pup, 0.08 * (0.5 + 0.5 * np.sin(dy * 50 - t * 3 + dx * 60)), I_in)
        sh = np.clip(m * 7.7, 0, 1)                                           # shadow cast by the lids
        I_in = I_in * (0.35 + 0.65 * sh * (2 - sh)) * gl + rim_amp * np.exp(-m * m * 1100.0)

        I = np.where(inside, I_in, I_out)

        # Bloom + vignette apply to the sky only; the landscape has its own lighting.
        I = I + 0.45 * blur(np.clip(I - 0.55, 0, None))
        I = I * self.vig

        # ---- landscape: three parallax layers, back to front ----
        xs = self.xs.astype(np.float64)
        sc = self.scroll
        far = 0.30 - 0.27 * (0.55 * tri(1.1 * (xs + sc * 0.25) + 0.3) + 0.30 * tri(2.7 * (xs + sc * 0.25) + 1.1)
                             + 0.15 * tri(6.3 * (xs + sc * 0.25) + 0.7))
        mid = 0.47 - 0.22 * (0.60 * tri(1.9 * (xs + sc * 0.55) + 0.6) + 0.30 * tri(4.4 * (xs + sc * 0.55) + 2.0)
                             + 0.10 * tri(9.0 * (xs + sc * 0.55) + 1.3))
        gnd = ground_y(xs, sc)
        I, m_far = self._mountain(I, far.astype(f32), fire, 0.16, 0.55, 0.85, sc * 0.25)
        I, m_mid = self._mountain(I, mid.astype(f32), fire, 0.40, 0.38, 0.85, sc * 0.55)
        I, m_gnd = self._ground(I, gnd.astype(f32), fire, sc)
        occ = m_far | m_mid | m_gnd

        # ---- the Fellowship: black silhouettes, rim-lit from the eye above ----
        fm = np.zeros((R, C), bool)
        sway = -(0.05 + 0.10 * gust)                    # cloaks stream to the left
        for sp in FELLOWSHIP:
            self._figure(sp, sc, self.walk + sp["off"], sway * (0.8 + 0.4 * sin(t * 3 + sp["off"])), fm)
        free = ~fm
        top = np.zeros_like(fm)
        top[1:] = free[:-1]                             # cell above is open sky
        side_r = np.zeros_like(fm)
        side_r[:, :-1] = free[:, 1:]
        side_l = np.zeros_like(fm)
        side_l[:, 1:] = free[:, :-1]
        side = np.where(self.U0 < EYE_CX, side_r, side_l)   # the side that faces the eye
        edge = fm & (top | side)
        rim = 0.95 * (fm & top) + 0.55 * (fm & side & ~top)
        lit = fire * (0.55 + 0.45 * self.light)
        I = np.where(fm, rim * lit, I)                  # interior stays black: a clean cut-out
        occ |= fm

        ci = np.clip((I * NP1).astype(np.int32), 0, NP1)    # colour level per cell

        # ---- pick a character for every cell ----
        inside &= ~occ
        rn = rng.random((R, C), dtype=f32)
        li_o = np.clip((I * LM + rn - 0.35).astype(np.int32), 0, LM)   # jittered outside
        li_i = np.clip((I * LM).astype(np.int32), 0, LM)               # clean inside
        codes = np.where(inside, RAMPC[li_i], RAMPC[li_o])
        tip = (rg > 0) & (rg < 0.07) & (~inside) & (~occ) & (I > 0.10) & (rn > 0.45)
        codes = np.where(tip, TIPC[(rn * 40).astype(np.int32) & 3], codes)
        dirm = inside & iris & (~pup) & (Ii > 0.20) & (Ii < 0.95) & (((rn * 13.7) % 1.0) < 0.62)
        dirc = DIRC[(np.mod(phi, PI) / PI * 4 + 0.5).astype(np.int32) & 3]
        codes = np.where(dirm, dirc, codes)
        codes = np.where(fm & edge, np.where(I > 0.5, ord("@"), ord("%")), codes).astype(np.uint8)
        cif, cof = ci.reshape(-1), codes.reshape(-1)

        # Embers drawn on top (hidden behind the mountains).
        self._embers(dt, fire, rage)
        E = self.E
        if len(E):
            half = self.half
            c = ((E[:, 0] * half + self.W / 2) / self.cw).astype(np.int32)
            r = ((E[:, 1] * half + self.H / 2) / self.ch).astype(np.int32)
            ok = (c >= 0) & (c < C) & (r >= 0) & (r < R)
            Ie = (1 - E[:, 4] / E[:, 5]) * (0.62 + 0.38 * np.sin(E[:, 4] * 18 + E[:, 6]))
            ok &= Ie > 0.12
            idx, Ie = r[ok] * C + c[ok], Ie[ok]
            fr = ~occ.reshape(-1)[idx]
            idx, Ie = idx[fr], Ie[fr]
            cie = np.clip((Ie * NP1).astype(np.int32), 0, NP1)
            mk = cie > cif[idx]
            cif[idx[mk]] = cie[mk]
            cof[idx[mk]] = np.where(Ie > 0.7, 42, np.where(Ie > 0.5, 43, np.where(Ie > 0.3, 39, 46)))[mk]

        # Blizzard in front of everything, lit by the eye's glow.
        if snow:
            self._snow(dt, gust)
            S = self.S
            c = ((S[:, 0] * self.half + self.W / 2) / self.cw).astype(np.int32)
            r = ((S[:, 1] * self.half + self.H / 2) / self.ch).astype(np.int32)
            ok = (c >= 0) & (c < C) & (r >= 0) & (r < R)
            Is = (0.22 + 0.36 * S[:, 5]) * min(1.0, 0.20 + fire * 0.85) * (0.7 + 0.3 * np.sin(t * 5 + S[:, 4]))
            idx, Is, big = r[ok] * C + c[ok], Is[ok], S[ok, 5]
            cs = np.clip((Is * NP1).astype(np.int32), 0, NP1)
            mk = (cs >= MIN_LEVEL) & (cs >= cif[idx] - 1)
            cif[idx[mk]] = cs[mk]
            cof[idx[mk]] = np.where(big[mk] > 0.7, 45, np.where(big[mk] > 0.35, 58, 46))   # '-' streak, ':', '.'

        # Film grain / dust.
        j = rng.integers(0, R * C, 14)
        j = j[cif[j] == 0]
        cif[j] = MIN_LEVEL + 1
        cof[j] = 46

        # ---- split into colour layers; each layer = its bounding box only ----
        out = [None] * NPAL
        for k in range(MIN_LEVEL, NPAL):
            mk = ci == k
            ra = mk.any(axis=1)
            if not ra.any():
                continue
            r0 = int(ra.argmax())
            r1 = R - 1 - int(ra[::-1].argmax())
            sub = mk[r0:r1 + 1]
            ca = sub.any(axis=0)
            c0 = int(ca.argmax())
            c1 = C - 1 - int(ca[::-1].argmax())
            blk = np.full((r1 - r0 + 1, c1 - c0 + 2), 10, np.uint8)       # last column = newline
            blk[:, :-1] = np.where(sub[:, c0:c1 + 1], codes[r0:r1 + 1, c0:c1 + 1], 32)
            text = blk.tobytes()[:-1].decode("ascii")
            text = "\n".join([ln.rstrip() for ln in text.split("\n")])    # trim blank tails
            out[k] = (text, c0, r0)
        return out


# ----------------------------------------------------------------------------
# Director: the "script" of the eye (sleep, wake, watch, rage, close)
# ----------------------------------------------------------------------------
class Director:
    def __init__(self, t):
        self.state = "sleep"; self.ts = t; self.dur = 1.8
        self.open = 0.0; self.open0 = 0.0          # eyelid opening (current / at phase start)
        self.fire = 0.14; self.fire0 = 0.14        # flame intensity
        self.rage = 0.0; self.rage_ts = None; self.rage_dur = 5.0
        self.next_rage = 1e18
        self.blink = 1.0; self.blink_ts = -9.0; self.blink_dur = 0.42
        self.next_blink = 1e18
        self.gx = self.gy = self.tx = self.ty = 0.0    # gaze (current / target)
        self.next_sacc = t + 2.0                       # next saccade (quick glance)
        self.mode = "idle"; self.mode_ts = t; self.next_sweep = t + 10.0
        self.mouse = None; self.mouse_t = -99.0
        self.dt = 0.016
        self.shake = 0.0
        self.gust = 0.4                                # wind strength for snow and cloaks

    def _go(self, state, t, dur):
        self.state, self.ts, self.dur = state, t, dur
        self.open0, self.fire0 = self.open, self.fire

    def toggle(self, t):
        """Wake the eye if it sleeps, otherwise start closing it."""
        if self.state in ("opening", "awake"):
            self._go("closing", t, 0.8 + 2.6 * self.open)
        else:
            self._go("opening", t, 0.8 + 4.2 * (1 - self.open))

    def update(self, t, dt):
        self.dt = dt
        p = (t - self.ts) / self.dur                   # progress of the current phase
        st = self.state
        if st == "sleep":
            self.open = 0.0
            self.fire = 0.14 + 0.04 * sin(t * 1.3)
            if p >= 1:
                self._go("opening", t, 5.0)
        elif st == "opening":
            e = smooth(p)
            # a little eyelid flutter while opening
            self.open = max(0.0, self.open0 + (1 - self.open0) * e + 0.05 * sin(p * 40) * e * (1 - e) * 4)
            self.fire = self.fire0 + (1.0 - self.fire0) * smooth(p * 1.15)
            if p >= 1:
                self._go("awake", t, random.uniform(22, 32))
                self.next_rage = t + random.uniform(7, 12)
                self.next_blink = t + random.uniform(3, 6)
        elif st == "awake":
            self.open = 1.0 + 0.025 * sin(t * 0.6)
            self.fire = 1.0 + 0.04 * sin(t * 1.1)
            if self.rage_ts is not None:
                rp = (t - self.rage_ts) / self.rage_dur
                if rp >= 1:
                    self.rage = 0.0
                    self.rage_ts = None
                    self.next_rage = t + random.uniform(9, 16)
                else:
                    self.rage = sin(PI * rp) ** 1.4
            elif t >= self.next_rage:
                self.rage_ts = t
            if self.rage_ts is None and t >= self.next_blink:
                self.blink_ts = t
                # sometimes a quick double blink
                self.next_blink = t + (0.7 if random.random() < 0.25 else random.uniform(6, 12))
            if p >= 1:
                self._go("closing", t, 3.4)
        elif st == "closing":
            e = smooth(p)
            self.open = self.open0 * (1 - e)
            self.fire = 0.14 + (self.fire0 - 0.14) * (1 - e)
            self.rage *= 0.97
            if p >= 1:
                self.rage = 0.0
                self.rage_ts = None
                self._go("sleep", t, 2.2)

        if st != "awake":
            self.rage = 0.0 if st != "closing" else self.rage
        self.open += 0.13 * self.rage              # the eye widens in rage
        self.fire += 0.35 * self.rage              # and the fire flares up
        self.shake = self.rage * self.rage
        # Wind: slow swells, a stronger gust whenever the eye rages.
        self.gust = 0.45 + 0.25 * sin(t * 0.37) + 0.20 * sin(t * 1.3 + 1.0) + 0.9 * self.rage

        pb = (t - self.blink_ts) / self.blink_dur
        self.blink = 1.0 - sin(PI * pb) ** 2 if 0.0 <= pb < 1.0 else 1.0

        # Gaze: follow the mouse if it moved recently, else watch the company below.
        bx, by = -0.05, 0.035                      # the Fellowship is down and a little to the left
        k = 10.0
        if self.mouse and t - self.mouse_t < 2.5:
            self.tx, self.ty = self.mouse[0] * 0.18, self.mouse[1] * 0.05
            k = 7.0
        elif self.mode == "sweep":
            ph = (t - self.mode_ts) / 6.5          # slowly search along the whole line of travellers
            if ph >= 1:
                self.mode = "idle"
                self.next_sweep = t + random.uniform(12, 20)
            else:
                self.tx = bx + 0.15 * sin(ph * 2 * PI)
                self.ty = by + 0.01 * sin(ph * 4 * PI)
                k = 3.0
        else:
            if t >= self.next_sacc:
                if random.random() < 0.35:         # a glance up at the sky
                    self.tx, self.ty = random.gauss(0, 0.04), random.gauss(-0.02, 0.01)
                else:
                    self.tx = bx + random.uniform(-0.12, 0.12)
                    self.ty = by + random.uniform(-0.02, 0.015)
                self.next_sacc = t + random.uniform(1.1, 3.4)
            if st == "awake" and t >= self.next_sweep and self.rage_ts is None:
                self.mode, self.mode_ts = "sweep", t
            k = 11.0
        w = 1.0 - 0.85 * self.rage                 # in rage the eye stares straight ahead
        self.gx += (self.tx * w - self.gx) * (1 - exp(-k * dt))
        self.gy += (self.ty * w - self.gy) * (1 - exp(-k * dt))
        self.gx += 0.0015 * sin(t * 17.0)          # tiny tremor

    def label(self):
        return {"sleep": "SLEEPING", "opening": "AWAKENING", "closing": "CLOSING",
                "awake": "ENRAGED" if self.rage > 0.4 else "WATCHING"}[self.state]


# ----------------------------------------------------------------------------
# GUI
# ----------------------------------------------------------------------------
class App:
    def __init__(self):
        self.root = root = tk.Tk()
        root.title("THE FELLOWSHIP AND THE EYE")
        root.configure(bg="#000000")
        root.resizable(False, False)
        avail = set(tkfont.families())
        self.fam = next((f for f in ("Cascadia Mono", "Consolas", "Menlo", "DejaVu Sans Mono",
                                     "Liberation Mono", "Courier New", "Courier") if f in avail), "Courier")
        self.cv = tk.Canvas(root, bg="#000000", highlightthickness=0, bd=0, cursor="arrow")
        self.cv.pack()
        self.status = tk.Label(root, text="", bg="#000000", fg="#5a1a0a", font=(self.fam, 9))
        self.status.pack(fill="x")
        self.snow = True
        self.t0 = time.perf_counter()
        self.last = self.t0
        self.dir = Director(0.0)
        self.fps = 30.0
        self.stat_t = 0.0
        self.build(START_LEVEL)

        root.bind("<space>", lambda e: self.dir.toggle(self.now()))
        root.bind("<Escape>", lambda e: root.destroy())
        root.bind("q", lambda e: root.destroy())
        root.bind("s", lambda e: setattr(self, "snow", not self.snow))
        root.bind("<plus>", lambda e: self.build(min(len(DETAIL) - 1, self.level + 1)))
        root.bind("<equal>", lambda e: self.build(min(len(DETAIL) - 1, self.level + 1)))
        root.bind("<minus>", lambda e: self.build(max(0, self.level - 1)))
        root.bind("<Motion>", self.on_motion)
        root.focus_force()
        self.tick()

    def build(self, level):
        """(Re)create the renderer, the canvas layers and the window size."""
        self.level = level
        cols = DETAIL[level]
        root = self.root
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        # Largest pixel font size whose grid still fits on the screen.
        for px in range(18, 5, -1):
            font = tkfont.Font(family=self.fam, size=-px)
            cw, chh = font.measure("M"), font.metrics("linespace")
            rows = round(cols * cw / chh)
            if cols * cw <= sw - 60 and rows * chh <= sh - 130:
                break
        self.font = font
        self.eye = Eye(cols, cw, chh)
        self.cv.delete("all")
        self.cv.config(width=self.eye.W, height=self.eye.H)
        # One text item per colour level; brighter levels do not overlap darker ones.
        self.items = [None] * NPAL
        for k in range(MIN_LEVEL, NPAL):
            self.items[k] = self.cv.create_text(0, 0, anchor="nw", font=font, text="",
                                                fill="#%02x%02x%02x" % PAL[k])
        self.prev_text = [""] * NPAL        # last text sent to each item
        self.prev_pos = [None] * NPAL       # last position sent to each item
        root.geometry("")
        root.update_idletasks()
        x = (sw - root.winfo_reqwidth()) // 2
        y = max(0, (sh - root.winfo_reqheight()) // 2 - 20)
        root.geometry("+%d+%d" % (x, y))
        self.built_at = time.perf_counter()

    def now(self):
        return time.perf_counter() - self.t0

    def on_motion(self, e):
        x = e.x_root - self.cv.winfo_rootx()
        y = e.y_root - self.cv.winfo_rooty()
        if 0 <= x <= self.eye.W and 0 <= y <= self.eye.H:
            self.dir.mouse = (x / self.eye.W * 2 - 1, y / self.eye.H * 2 - 1)
            self.dir.mouse_t = self.now()

    def tick(self):
        s = time.perf_counter()
        t = s - self.t0
        dt = min(0.1, s - self.last)
        self.last = s
        d = self.dir
        d.update(t, dt)
        layers = self.eye.render(t, d, self.snow)

        cv, cw, ch = self.cv, self.eye.cw, self.eye.ch
        sx = sy = 0
        if d.shake > 0.02:                           # pixel shake during rage
            m = int(1 + 3 * d.shake)
            sx, sy = random.randint(-m, m), random.randint(-m, m)
        prev_text, prev_pos, items = self.prev_text, self.prev_pos, self.items
        for k in range(MIN_LEVEL, NPAL):
            e = layers[k]
            if e is None:
                if prev_text[k]:
                    cv.itemconfigure(items[k], text="")
                    prev_text[k] = ""
                continue
            if e[0] != prev_text[k]:                 # skip layers that did not change
                cv.itemconfigure(items[k], text=e[0])
                prev_text[k] = e[0]
            pos = (e[1] * cw + sx, e[2] * ch + sy)
            if pos != prev_pos[k]:
                cv.coords(items[k], pos[0], pos[1])
                prev_pos[k] = pos
        cv.update_idletasks()

        self.fps = self.fps * 0.93 + (1.0 / max(dt, 1e-3)) * 0.07
        if t - self.stat_t > 0.5:
            self.stat_t = t
            self.status.config(text="%s  |  SPACE wake/sleep  |  mouse = gaze  |  +/- detail %dx%d  |  S blizzard  |  ESC quit  |  %d fps"
                               % (d.label(), self.eye.cols, self.eye.rows, self.fps))
        # Too slow? Drop one detail step (checked only after the grid has settled).
        if self.level > 0 and s - self.built_at > 6.0 and self.fps < AUTO_DOWNGRADE_FPS:
            self.build(self.level - 1)
            self.fps = 30.0
        el = time.perf_counter() - s
        self.root.after(max(1, int(1000 / TARGET_FPS - el * 1000)), self.tick)


if __name__ == "__main__":
    App().root.mainloop()
