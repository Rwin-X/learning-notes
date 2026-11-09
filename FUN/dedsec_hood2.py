
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
# تنظیمات کلی
# ----------------------------------------------------------------------------
DETAIL = [100, 120, 140, 160]
START_LEVEL = 2
TARGET_FPS = 60
AUTO_DOWNGRADE_FPS = 24

f32 = np.float32
sin, cos, exp, sqrt = math.sin, math.cos, math.exp, math.sqrt
PI = math.pi

# چگالی گلیف‌ها از تیره به روشن -- برای سایه‌زنی نرم جمجمه و حلقه
RAMP = " .:-=+*#%@"
NRAMP = len(RAMP)
GLY_RAIN = np.frombuffer(b"01", np.uint8)

# ---- دنباله‌ی بوت: هر خط با سرعت خودش تایپ می‌شود، سپس یک مکث کوتاه ----
BOOT_LINES = [
    ("root@dedsec:~$ ./init --target=hood.render", 0.018, 0.35),
    ("", 0.0, 0.12),
    ("[ OK ] kernel handshake", 0.012, 0.10),
    ("[ OK ] loading phosphor palette", 0.012, 0.10),
    ("[ OK ] tracing hood silhouette", 0.012, 0.10),
    ("[ OK ] compositing cranial mesh", 0.012, 0.10),
    ("[ OK ] weaving shoulder fabric", 0.012, 0.10),
    ("[ OK ] calibrating ocular glow", 0.012, 0.22),
    ("", 0.0, 0.10),
    ("WE ARE DEDSEC", 0.045, 0.30),
    ("WE DO NOT FORGIVE // WE DO NOT FORGET", 0.022, 0.55),
]
BOOT_TOTAL_CHARS = sum(len(s) for s, _, _ in BOOT_LINES)


def smooth(x):
    x = 0.0 if x < 0 else (1.0 if x > 1 else x)
    return x * x * x * (x * (6 * x - 15) + 10)


def make_palette(hue, flash, n=NRAMP):
    """n-step intensity ramp -> RGB, green phosphor by default, shifts red on alert (hue)."""
    base = (30 + 225 * hue, 255 - 205 * hue, 90 - 60 * hue)
    pal = []
    for k in range(n):
        b = k / (n - 1)
        if b < 0.75:
            f = (b / 0.75) ** 0.85
            col = [c * (0.08 + 0.92 * f) for c in base]
        else:
            f = (b - 0.75) / 0.25
            col = [c + (255 - c) * 0.85 * f for c in base]
        col = [c + (255 - c) * flash * 0.7 for c in col]
        pal.append(tuple(int(max(0, min(255, c))) for c in col))
    return pal


# ----------------------------------------------------------------------------
# Scene: all geometry built once per detail-level, animated every frame
# ----------------------------------------------------------------------------
class Scene:
    def __init__(self, cols, cw, ch):
        self.cols, self.cw, self.ch = cols, cw, ch
        # frame is taller than wide (portrait) so the full hood ring + shoulders fit
        rows = self.rows = max(34, round(cols * cw / ch * 1.30))
        self.W, self.H = cols * cw, rows * ch
        half = self.half = self.W / 2.0
        # normalized coords: X in [-W/H_aspect..], Y uses the same per-pixel scale as X
        # so a circle stays a circle once we also correct for char cell aspect ratio.
        xs = (((np.arange(cols) + 0.5) * cw - self.W / 2) / half).astype(f32)
        ys = (((np.arange(rows) + 0.5) * ch - self.H / 2) / half).astype(f32)
        self.X = np.ascontiguousarray(np.broadcast_to(xs, (rows, cols)))
        # ring/skull are authored around local origin (0,0) = ring center;
        # shift down slightly so there is a little headroom above the ring.
        self.Y0 = 0.08
        self.Y = np.ascontiguousarray(np.broadcast_to(ys[:, None] - self.Y0, (rows, cols)))
        rad0 = np.hypot(self.X, self.Y)
        # vignette: keep full brightness out to just past the ring radius, only
        # darken the far corners beyond it, so the ring itself is never crushed.
        self.vig = np.clip(1.0 - 0.35 * np.clip(rad0 - 1.05, 0, None) ** 2, 0.35, 1.0).astype(f32)

        rng = self.rng = np.random.default_rng()
        self.spd = (4 + 10 * rng.random(cols)).astype(f32)
        self.ph = (rng.random(cols) * (rows + 30)).astype(f32)
        self.ln = (5 + rng.random(cols) * 14).astype(f32)
        self.col_on = (rng.random(cols) < 0.22).astype(f32)   # sparse rain columns
        self.rr = np.arange(rows)[:, None]
        self.glyph_seed = rng.integers(0, 2, (rows, cols))

        self._build_skull_field()
        self._build_hud_frame()
        self.dyn_log = []
        self.next_log = 0.0
        self.boot_chars_shown = 0

    # ---- metaball skull field (static geometry; eyes/jaw animate per-frame) ----
    # All skull geometry below is authored in local coords (sx, sy) where the
    # cranium top is near sy=0 and the chin is near sy=1; SK_SCALE/SK_Y0 map
    # that into the scene's ring-centered (X, Y) space so the skull sits
    # comfortably inside the upper half of the hood ring.
    SK_SCALE = 0.62
    SK_Y0 = -0.46   # Y position (scene space) of the skull's local sy=0

    def _build_skull_field(self):
        X = self.X / self.SK_SCALE
        Y = (self.Y - self.SK_Y0) / self.SK_SCALE

        def blob(cx, cy, r, s=1.0):
            d2 = (X - cx) ** 2 + (Y - cy) ** 2
            return s * (r * r) / (d2 + 1e-5)

        field = np.zeros_like(X)
        field += blob(0.00, 0.12, 0.40, 1.0)
        field += blob(-0.27, 0.22, 0.30, 0.92)
        field += blob(0.27, 0.22, 0.30, 0.92)
        field += blob(0.00, 0.38, 0.37, 1.0)
        field += blob(-0.37, 0.42, 0.21, 0.62)
        field += blob(0.37, 0.42, 0.21, 0.62)
        field += blob(-0.35, 0.57, 0.18, 0.64)
        field += blob(0.35, 0.57, 0.18, 0.64)
        field += blob(0.00, 0.57, 0.30, 0.68)
        field -= blob(-0.30, 0.70, 0.10, 0.35)
        field -= blob(0.30, 0.70, 0.10, 0.35)
        field += blob(0.00, 0.75, 0.26, 0.85)
        field += blob(-0.15, 0.80, 0.155, 0.55)
        field += blob(0.15, 0.80, 0.155, 0.55)
        field += blob(0.00, 0.94, 0.205, 0.80)
        field += blob(0.00, 1.07, 0.165, 0.78)
        field += blob(0.00, 1.17, 0.135, 0.72)
        field += blob(0.00, 1.25, 0.095, 0.58)
        self.skull_field = field
        self.skull_iso = 2.15

        def socket(cx, cy, rx, ry, tilt=0.0):
            xr = X - cx
            yr = (Y - cy) - tilt * xr
            return ((xr / rx) ** 2 + (yr / ry) ** 2) < 1.0
        self.sock_l = socket(-0.21, 0.42, 0.135, 0.115, tilt=0.15)
        self.sock_r = socket(0.21, 0.42, 0.135, 0.115, tilt=-0.15)
        ny = np.clip((Y - 0.50) / 0.15, 0, 1)
        self.nose = (np.abs(X) < (0.010 + 0.075 * ny)) & (Y > 0.50) & (Y < 0.66)
        self.teeth_band = (Y > 0.82) & (Y < 0.93)
        self.teeth_gap_x = np.mod((X + 0.30) / 0.075, 1.0) < 0.14
        self.skull_Y_local = Y  # kept for the vertical scan-reveal (assemble stage)

        # rim = near the boundary of the mask (recomputed once; geometry is static)
        mask = field > self.skull_iso
        pad = np.pad(mask, 1)
        eroded = pad[1:-1, 1:-1] & pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:]
        self.skull_mask_base = mask
        self.rim_base = mask & ~eroded

        # hood ring geometry -- centered on the scene origin (0,0)
        rad = np.hypot(self.X, self.Y)
        ang = np.arctan2(self.Y, self.X)
        self.ring_rad = rad
        self.ring_ang = ang
        self.ring_base_mid = 1.0

        # shoulders geometry (scene space): drape below the ring's open bottom
        SX, SY = self.X, self.Y
        curve_l = 0.62 + 0.55 * np.sqrt(np.clip(-SX + 0.03, 0, None))
        curve_r = 0.62 + 0.55 * np.sqrt(np.clip(SX + 0.03, 0, None))
        self.shoulder_l = np.clip(1.0 - np.abs((SY - curve_l) / 0.50), 0, 1) * (SX < 0.05) * (SY > 0.48)
        self.shoulder_r = np.clip(1.0 - np.abs((SY - curve_r) / 0.50), 0, 1) * (SX >= 0.05) * (SY > 0.48)

    def _build_hud_frame(self):
        R, C = self.rows, self.cols
        fc = np.zeros((R, C), np.uint8)
        fm = np.zeros((R, C), bool)
        bl, bh = max(7, C // 14), max(2, R // 18)

        def put(r, c, ch):
            if 0 <= r < R and 0 <= c < C:
                fc[r, c] = ord(ch)
                fm[r, c] = True

        for (r, c, sr, sc) in ((1, 1, 1, 1), (1, C - 2, 1, -1), (R - 2, 1, -1, 1), (R - 2, C - 2, -1, -1)):
            put(r, c, "+")
            for i in range(1, bl):
                put(r, c + sc * i, "-")
            for i in range(1, bh):
                put(r + sr * i, c, "|")
        self.frame_c, self.frame_m = fc, fm

    def _put(self, tc, tm, ti, r, c, s, inten):
        if r < 0 or r >= self.rows or not s:
            return
        c0, c1 = max(c, 0), min(c + len(s), self.cols)
        if c1 <= c0:
            return
        seg = np.frombuffer(s.encode("ascii", "replace"), np.uint8)[c0 - c:c1 - c]
        tc[r, c0:c1] = seg
        tm[r, c0:c1] = True
        ti[r, c0:c1] = np.maximum(ti[r, c0:c1], inten)

    @staticmethod
    def _logline():
        ip = "%d.%d.%d.%d" % (random.randrange(1, 255), random.randrange(256),
                               random.randrange(256), random.randrange(1, 255))
        return random.choice([
            "scan %s :: open" % ip,
            "handshake accepted <- %s" % ip,
            "payload sync 0x%06X" % random.randrange(1 << 24),
            "uplink stable // %d%%" % random.randrange(70, 100),
            "node %03d :: silent" % random.randrange(1000),
            "trace route complete",
        ])

    # ---- compute intensity + glyph-code arrays for one frame ----
    def render(self, t, d):
        X, Y, R, C = self.X, self.Y, self.rows, self.cols
        rng = self.rng

        # ---- ambient background: faint sparse drifting 0/1 rain ----
        head = np.mod(t * self.spd + self.ph, R + 20)
        dist = head[None, :] - self.rr
        tail = (dist >= 0) & (dist < self.ln[None, :])
        rain_i = np.where(tail, np.clip(1 - dist / self.ln[None, :], 0, 1) ** 2, 0.0) * 0.30
        rain_i *= self.col_on[None, :] * d.rain
        rain_code = GLY_RAIN[(self.glyph_seed + int(t * 4)) % 2]

        I = rain_i
        code = np.where(rain_i > 0, rain_code, ord(" ")).astype(np.uint8)

        # ---- hood ring: soft glowing circle, opening fades at bottom ----
        if d.hood > 0.005:
            wobble = 0.006 * sin(t * 0.5)
            ring_glow = np.exp(-((self.ring_rad - (self.ring_base_mid + wobble)) / 0.040) ** 2)
            bottom_fade = np.clip((np.abs(self.ring_ang - PI / 2) - 0.35) / 0.55, 0, 1)
            ring_glow = ring_glow * np.where(np.abs(self.ring_ang - PI / 2) < 0.9, bottom_fade, 1.0)
            ring_glow *= d.hood
            ring_on = ring_glow > 0.05
            denser = np.where(np.sin(self.ring_rad * 70 - t * 1.2) > 0.1, ord("="), ord("-"))
            better = ring_on & (ring_glow > I)
            I = np.where(better, ring_glow, I)
            code = np.where(better, denser, code)

        # ---- shoulders / hood fabric ----
        if d.shoulders > 0.005:
            sh = np.maximum(self.shoulder_l, self.shoulder_r) * 0.42 * d.shoulders
            fold = (np.sin(X * 18 + Y * 3 + t * 0.3) > 0.72) & (sh > 0.05)
            sh = np.where(fold, sh * 1.4, sh)
            better = (sh > I)
            I = np.where(better, sh, I)
            code = np.where(better & fold, ord("/"), np.where(better, ord("."), code))

        # ---- skull ----
        if d.skull > 0.005:
            Ys = self.skull_Y_local  # local skull-space Y (0=cranium top area .. 1.3=chin)
            field = self.skull_field
            mask = field > self.skull_iso
            sock = self.sock_l | self.sock_r
            teeth_gap = self.teeth_band & self.teeth_gap_x & mask
            mask = mask & ~sock & ~self.nose & ~teeth_gap

            # reveal via vertical scan (assemble stage) + dissolve (purge stage)
            scan_y = d.sk_scan
            vis = (Ys < scan_y)
            if d.dissolve > 0.001:
                dn = (self.glyph_seed + int(t * 13)) % 2
                vis &= (dn > 0) | (rng.random((R, C)) > d.dissolve)
            mask_vis = mask & vis

            inten = np.clip((field - self.skull_iso) / 1.4, 0, 1) ** 0.6
            S = 0.46 + 0.30 * inten
            S = np.where(self.rim_base & mask_vis, 0.97, S)
            S *= d.skull

            better = mask_vis & (S > I)
            I = np.where(better, S, I)
            bone_glyph = np.where(((self.glyph_seed + int(t * 1.5)) & 1) == 0, ord("%"), ord("#"))
            rim_glyph = np.where(S > 0.9, ord("@"), bone_glyph)
            code = np.where(better, np.where(self.rim_base, rim_glyph, bone_glyph), code)

            # eye glow (tracks mouse / autonomous saccade via d.gx,d.gy) -- in scene space
            eyevis = sock & vis
            if eyevis.any():
                flick = 0.75 + 0.25 * sin(t * 10)
                base_e = 0.05 * flick
                Ie = np.where(eyevis, base_e, 0.0) * d.skull
                better_e = eyevis & (Ie > I)
                I = np.where(better_e, Ie, I)
                code = np.where(better_e, ord(":"), code)
                sc = self.SK_SCALE
                for sgn, sockm in ((-1.0, self.sock_l), (1.0, self.sock_r)):
                    ex = (sgn * 0.21 + d.gx * 0.045) * sc
                    ey = self.SK_Y0 + (0.42 + d.gy * 0.035) * sc
                    r = np.hypot(X - ex, Y - ey)
                    ring_e = np.exp(-((r - 0.045 * sc) / (0.014 * sc)) ** 2)
                    dot = r < 0.016 * sc
                    e = np.maximum(ring_e, dot * 1.0) * (0.85 + 0.15 * sin(t * 15 + sgn)) * d.skull
                    m = sockm & vis & (e > 0.08)
                    I = np.where(m, np.maximum(I, e), I)
                    code = np.where(m & dot, ord("@"), np.where(m & (ring_e > 0.3), ord("o"), code))

            # scan-line glint while assembling (drawn in scene space at the scan's mapped Y)
            if 0.0 < scan_y < 1.6:
                scan_Y_scene = self.SK_Y0 + scan_y * self.SK_SCALE
                scan_band = (np.abs(Y - scan_Y_scene) < 0.015) & (np.abs(X) < 0.60 * self.SK_SCALE / 0.62)
                I = np.where(scan_band, 1.0, I)
                code = np.where(scan_band, ord("="), code)

        # ---- text overlays: HUD frame, boot terminal, logs, alert ----
        tc = np.zeros((R, C), np.uint8)
        tm_ = np.zeros((R, C), bool)
        ti = np.zeros((R, C), f32)

        if d.hud > 0.01:
            fm = self.frame_m
            tc[fm] = self.frame_c[fm]
            tm_ |= fm
            ti[fm] = np.maximum(ti[fm], 0.45 * d.hud)
            self._put(tc, tm_, ti, 1, 3, "DEDSEC // HOOD", 0.85 * d.hud)
            tag = "[ %s ]" % d.label()
            self._put(tc, tm_, ti, 1, C - 3 - len(tag), tag, 0.85 * d.hud)
            if d.stage == "live":
                if t >= self.next_log:
                    self.dyn_log.append(self._logline())
                    self.dyn_log = self.dyn_log[-4:]
                    self.next_log = t + random.uniform(0.6, 1.4)
                for i, s in enumerate(self.dyn_log):
                    age = len(self.dyn_log) - 1 - i
                    self._put(tc, tm_, ti, R - 2 - (len(self.dyn_log) - i), 3, s,
                              (0.55 if age == 0 else 0.35) * d.hud)

        if d.boot_vis > 0.01:
            self._render_boot(t, d, tc, tm_, ti)

        if d.alert > 0.25 and int(t * 4) % 2 == 0:
            s = "!! INTRUSION DETECTED !!"
            self._put(tc, tm_, ti, 3, (C - len(s)) // 2, s, 1.0)

        over = tm_ & (ti >= I)
        I = np.where(over, ti, I)
        code = np.where(over, tc, code)

        # ---- post: gentle scanlines, vignette, subtle flicker, glitch ----
        I = I * np.where((self.rr.flatten()[:, None] & 1) == 1, 0.92, 1.0)
        I = I * (0.985 + 0.015 * sin(t * 41))
        I = I * self.vig

        g = d.glitch
        if g > 0.04:
            for _ in range(int(1 + g * 5)):
                r0 = int(rng.integers(0, R))
                r1 = min(R, r0 + int(rng.integers(1, 2 + int(3 * g))))
                sh = int(rng.integers(-1, 2)) * int(rng.integers(1, 4 + int(14 * g)))
                if sh:
                    I[r0:r1] = np.roll(I[r0:r1], sh, axis=1)
                    code[r0:r1] = np.roll(code[r0:r1], sh, axis=1)

        code = np.clip(code, 32, 126).astype(np.uint8)
        ci = np.clip((I * (NRAMP - 1)).astype(np.int32), 0, NRAMP - 1)

        out = [None] * NRAMP
        for k in range(1, NRAMP):
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
            blk = np.full((r1 - r0 + 1, c1 - c0 + 2), 10, np.uint8)
            blk[:, :-1] = np.where(sub[:, c0:c1 + 1], code[r0:r1 + 1, c0:c1 + 1], 32)
            text = blk.tobytes()[:-1].decode("ascii")
            text = "\n".join(ln.rstrip() for ln in text.split("\n"))
            out[k] = (text, c0, r0)
        return out

    # ---- boot sequence: typewriter, well-paced, centered ----
    def _render_boot(self, t, d, tc, tm_, ti):
        R, C = self.rows, self.cols
        lines_done = []
        remaining = d.boot_chars
        cursor_line = None
        for text, speed, pause in BOOT_LINES:
            if remaining <= 0:
                break
            n = min(len(text), remaining)
            shown = text[:n]
            lines_done.append(shown)
            remaining -= len(text)
            cursor_line = (shown, n >= len(text) and remaining <= 0)
        if not lines_done:
            return
        r0 = R // 2 - len(lines_done) // 2 - 2
        blink = int(t * 2.4) % 2 == 0
        for i, s in enumerate(lines_done):
            is_last = (i == len(lines_done) - 1)
            cur = "_" if (is_last and blink and d.boot_chars < BOOT_TOTAL_CHARS) else ""
            inten = 0.95 if is_last else 0.55
            self._put(tc, tm_, ti, r0 + i, (C - max(len(s), 1)) // 2, s + cur, inten * d.boot_vis)


# ----------------------------------------------------------------------------
# Director: stage machine (boot -> assemble -> live -> purge -> repeat)
# ----------------------------------------------------------------------------
BOOT_DUR = 5.2
ASSEMBLE_DUR = 3.0
PURGE_DUR = 2.4


class Director:
    def __init__(self, t):
        self.t0 = t
        self.mouse = None
        self.mouse_t = -99.0
        self.gx = self.gy = self.tx = self.ty = 0.0
        self.next_sacc = t + 1.0
        self.reset(t)

    def reset(self, t):
        self.stage, self.ts, self.dur = "boot", t, BOOT_DUR
        self.boot_chars = 0
        self.boot_vis = 1.0
        self.rain = 0.25
        self.hud = 0.0
        self.hood = 0.0
        self.shoulders = 0.0
        self.skull = 0.0
        self.sk_scan = -0.3
        self.dissolve = 0.0
        self.jaw = 0.0
        self.glitch = 0.05
        self.hue = 0.0
        self.flash = 0.0
        self.alert = 0.0
        self.alert_ts = None
        self.next_alert = 1e18

    def toggle_alert(self, t):
        if self.stage == "live":
            self.alert_ts = None if self.alert_ts is not None else t

    def label(self):
        return self.stage.upper() + (" / ALERT" if self.alert > 0.3 else "")

    def update(self, t, dt):
        p = (t - self.ts) / self.dur
        st = self.stage
        base_glitch = 0.03
        if st == "boot":
            self.boot_chars = int(min(1.0, p) * BOOT_TOTAL_CHARS)
            self.boot_vis = 1.0
            self.rain = 0.30
            self.hud = 0.0
            if p >= 1:
                self.stage, self.ts, self.dur = "assemble", t, ASSEMBLE_DUR
        elif st == "assemble":
            self.boot_vis = max(0.0, 1.0 - smooth(p * 3.2))
            self.hud = smooth(p / 0.5)
            self.rain = 0.6
            self.hood = smooth(p / 0.6)
            self.shoulders = smooth((p - 0.25) / 0.6)
            self.skull = 1.0
            self.sk_scan = -0.3 + 2.0 * smooth(p / 0.85)
            base_glitch = 0.22 * (1 - p) + 0.03
            if p >= 1:
                self.stage, self.ts, self.dur = "live", t, random.uniform(28, 38)
                self.next_alert = t + random.uniform(10, 16)
        elif st == "live":
            self.sk_scan, self.hood, self.shoulders, self.skull = 1.8, 1.0, 1.0, 1.0
            self.hud, self.rain, self.boot_vis = 1.0, 0.55, 0.0
            self.jaw = 0.0
            if self.alert_ts is None and t >= self.next_alert:
                self.alert_ts = t
            if p >= 1:
                self.alert_ts = None
                self.stage, self.ts, self.dur = "purge", t, PURGE_DUR
        elif st == "purge":
            e = smooth(p)
            self.dissolve = e
            self.hood = 1 - smooth(p * 1.3)
            self.shoulders = 1 - smooth(p * 1.3)
            self.hud = 1 - smooth(p * 1.5)
            self.rain = 0.55 - 0.3 * e
            base_glitch = 0.10 + 0.35 * e
            if p >= 1:
                self.reset(t)
                return
        if self.alert_ts is not None and st == "live":
            ap = (t - self.alert_ts) / 4.5
            if ap >= 1:
                self.alert_ts = None
                self.next_alert = t + random.uniform(12, 18)
                self.alert = 0.0
            else:
                self.alert = sin(PI * ap) ** 0.7
        else:
            self.alert *= 0.92
        self.hue += (min(1.0, self.alert * 1.5) - self.hue) * (1 - exp(-5 * dt))
        self.flash = 0.22 * self.alert * max(0.0, sin(t * 8))
        self.glitch = max(base_glitch, 0.5 * self.alert)

        k = 7.0
        if self.mouse and t - self.mouse_t < 2.2:
            self.tx, self.ty = self.mouse
        elif t >= self.next_sacc:
            self.tx, self.ty = random.uniform(-1, 1), random.uniform(-0.7, 0.7)
            self.next_sacc = t + random.uniform(1.2, 3.0)
        self.gx += (self.tx - self.gx) * (1 - exp(-k * dt))
        self.gy += (self.ty - self.gy) * (1 - exp(-k * dt))


# ----------------------------------------------------------------------------
# GUI
# ----------------------------------------------------------------------------
class App:
    def __init__(self):
        self.root = root = tk.Tk()
        root.title("DEDSEC :: HOOD")
        root.configure(bg="#000000")
        root.resizable(False, False)
        avail = set(tkfont.families())
        self.fam = next((f for f in ("Cascadia Mono", "Consolas", "Menlo", "DejaVu Sans Mono",
                                     "Liberation Mono", "Courier New", "Courier") if f in avail), "Courier")
        self.cv = tk.Canvas(root, bg="#000000", highlightthickness=0, bd=0, cursor="arrow")
        self.cv.pack()
        self.status = tk.Label(root, text="", bg="#000000", fg="#1f6b2a", font=(self.fam, 9))
        self.status.pack(fill="x")
        self.t0 = time.perf_counter()
        self.last = self.t0
        self.dir = Director(0.0)
        self.fps = 30.0
        self.stat_t = 0.0
        self.pal_key = None
        self.build(START_LEVEL)

        root.bind("<space>", lambda e: self._burst())
        root.bind("a", lambda e: self.dir.toggle_alert(self.now()))
        root.bind("A", lambda e: self.dir.toggle_alert(self.now()))
        root.bind("r", lambda e: self.dir.reset(self.now()))
        root.bind("R", lambda e: self.dir.reset(self.now()))
        root.bind("<Escape>", lambda e: root.destroy())
        root.bind("q", lambda e: root.destroy())
        root.bind("Q", lambda e: root.destroy())
        root.bind("<plus>", lambda e: self.build(min(len(DETAIL) - 1, self.level + 1)))
        root.bind("<equal>", lambda e: self.build(min(len(DETAIL) - 1, self.level + 1)))
        root.bind("<minus>", lambda e: self.build(max(0, self.level - 1)))
        root.bind("<Motion>", self.on_motion)
        root.focus_force()
        self.tick()

    def _burst(self):
        self.dir.glitch = max(self.dir.glitch, 0.8)

    def build(self, level):
        self.level = level
        cols = DETAIL[level]
        root = self.root
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        for px in range(16, 5, -1):
            font = tkfont.Font(family=self.fam, size=-px)
            cw, chh = font.measure("M"), font.metrics("linespace")
            rows = round(cols * cw / chh * 1.05)
            if cols * cw <= sw - 60 and rows * chh <= sh - 130:
                break
        self.font = font
        self.scene = Scene(cols, cw, chh)
        self.cv.delete("all")
        self.cv.config(width=self.scene.W, height=self.scene.H)
        pal = make_palette(0.0, 0.0)
        self.items = [None] * NRAMP
        for k in range(1, NRAMP):
            self.items[k] = self.cv.create_text(0, 0, anchor="nw", font=font, text="",
                                                fill="#%02x%02x%02x" % pal[k])
        self.pal_key = (0.0, 0.0)
        self.prev_text = [""] * NRAMP
        self.prev_pos = [None] * NRAMP
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
        if 0 <= x <= self.scene.W and 0 <= y <= self.scene.H:
            self.dir.mouse = (x / self.scene.W * 2 - 1, y / self.scene.H * 2 - 1)
            self.dir.mouse_t = self.now()

    def tick(self):
        s = time.perf_counter()
        t = s - self.t0
        dt = min(0.1, s - self.last)
        self.last = s
        d = self.dir
        d.update(t, dt)
        layers = self.scene.render(t, d)

        cv = self.cv
        cw, ch = self.scene.cw, self.scene.ch
        key = (round(d.hue, 2), round(d.flash, 2))
        if key != self.pal_key:
            pal = make_palette(d.hue, d.flash)
            for k in range(1, NRAMP):
                cv.itemconfigure(self.items[k], fill="#%02x%02x%02x" % pal[k])
            self.pal_key = key

        prev_text, prev_pos, items = self.prev_text, self.prev_pos, self.items
        for k in range(1, NRAMP):
            e = layers[k]
            if e is None:
                if prev_text[k]:
                    cv.itemconfigure(items[k], text="")
                    prev_text[k] = ""
                continue
            if e[0] != prev_text[k]:
                cv.itemconfigure(items[k], text=e[0])
                prev_text[k] = e[0]
            pos = (e[1] * cw, e[2] * ch)
            if pos != prev_pos[k]:
                cv.coords(items[k], pos[0], pos[1])
                prev_pos[k] = pos
        cv.update_idletasks()

        self.fps = self.fps * 0.92 + (1.0 / max(dt, 1e-3)) * 0.08
        if t - self.stat_t > 0.5:
            self.stat_t = t
            self.status.config(
                text="%s  |  SPACE glitch  |  A alert  |  R reboot  |  mouse = gaze  |  +/- detail %dx%d  |  ESC quit  |  %d fps"
                % (d.label(), self.scene.cols, self.scene.rows, self.fps))
        if self.level > 0 and s - self.built_at > 6.0 and self.fps < AUTO_DOWNGRADE_FPS:
            self.build(self.level - 1)
            self.fps = 30.0
        el = time.perf_counter() - s
        self.root.after(max(1, int(1000 / TARGET_FPS - el * 1000)), self.tick)


if __name__ == "__main__":
    App().root.mainloop()
