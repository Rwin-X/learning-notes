#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DEDSEC :: HOOD - یک صحنه‌ی زنده‌ی اسکی‌آرت (numpy + tkinter)

کاملاً مثل dedsec.py همه‌چیز با ریاضی و به‌صورت رویه‌ای (procedural) تولید می‌شود؛
هیچ فایل عکسی در زمان اجرا خوانده نمی‌شود. این نسخه ترکیب‌بندی عکس شما را
شبیه‌سازی می‌کند: یک حلقه‌ی هود بزرگ و دایره‌ای که کل صحنه را احاطه کرده،
یک جمجمه‌ی درخشان در مرکز آن (از dedsec.py اقتباس‌شده) و شانه‌ها/پارچه‌ی
هودی که در پایین صحنه گسترده می‌شود -- همه با بارش کد، گلیچ، و افکت CRT زنده.

نصب:  pip install numpy          (tkinter همراه پایتون نصب است)
اجرا:  python dedsec_hood.py

کنترل‌ها
  SPACE      یک گلیچ لحظه‌ای ایجاد کن
  A          هشدار قرمز را روشن/خاموش کن
  R          کل صحنه را دوباره راه‌اندازی کن (ریبوت)
  mouse      چشم‌های رتیکل جمجمه موس را دنبال می‌کنند
  + / -      جزئیات بیشتر / کمتر (اندازه‌ی شبکه کاراکتری)
  ESC / Q    خروج
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
# تنظیمات
# ----------------------------------------------------------------------------
DETAIL = [96, 120, 144, 168, 192]
START_LEVEL = 2
TARGET_FPS = 120
NG = 14
MIN_LEVEL = 2
AUTO_DOWNGRADE_FPS = 30
ACC_CY, ACC_MG, ACC_WH = NG, NG + 1, NG + 2
NLAYER = NG + 3
BOOT_DUR, ASSEMBLE_DUR, PURGE_DUR = 7.0, 4.5, 3.2

NG1 = NG - 1
GLY = np.frombuffer(b"0123456789ABCDEF<>/\\|{}[]=+*#$%&@:;", np.uint8)
NGLY = len(GLY)
f32 = np.float32
sin, cos, exp = math.sin, math.cos, math.exp
PI = math.pi

BOOT = [
    "root@dedsec:~# ./render --mode=hood",
    "[*] tracing hood silhouette ........ OK",
    "[*] compositing skull core ......... OK",
    "[*] weaving shoulder fabric ........ OK",
    "[*] syncing phosphor palette ....... OK",
    "[+] portrait online",
]
BOOT_TOTAL = sum(len(s) + 1 for s in BOOT)


def make_palette(hue, flash):
    base = (0.0 + 255 * hue, 255 - 215 * hue, 70 - 40 * hue)
    pal = []
    for k in range(NG):
        b = k / NG1
        if b < 0.7:
            f = b / 0.7
            col = [c * (0.10 + 0.90 * f) * f ** 0.5 for c in base]
        else:
            f = (b - 0.7) / 0.3
            col = [c + (255 - c) * 0.80 * f for c in base]
        col = [c + (255 - c) * flash * 0.8 for c in col]
        pal.append(tuple(int(max(0, min(255, c))) for c in col))
    pal.append((0, 230, 255))
    pal.append((255, 30, 160))
    pal.append((235, 255, 240))
    return pal


def smooth(x):
    x = 0.0 if x < 0 else (1.0 if x > 1 else x)
    return x * x * x * (x * (6 * x - 15) + 10)


def blur(a):
    for _ in range(2):
        p = a.copy()
        p[:, 1:] += 0.6 * a[:, :-1]
        p[:, :-1] += 0.6 * a[:, 1:]
        q = p.copy()
        q[1:] += 0.5 * p[:-1]
        q[:-1] += 0.5 * p[1:]
        a = q * 0.23
    return a


# ----------------------------------------------------------------------------
# Scene
# ----------------------------------------------------------------------------
class Scene:
    SK = 0.78
    SK_TOP = -0.62          # skull sits a bit higher, leaving room for the hood ring above it

    def __init__(self, cols, cw, ch):
        self.cols, self.cw, self.ch = cols, cw, ch
        R = self.rows = max(24, round(cols * cw / ch))
        C = cols
        self.W, self.H = cols * cw, R * ch
        half = self.half = self.W / 2.0
        self.du, self.dv = 2.0 / cols, ch / half
        self.v0 = (0.5 * ch - self.H / 2) / half
        xs = (((np.arange(C) + 0.5) * cw - self.W / 2) / half).astype(f32)
        ys = (((np.arange(R) + 0.5) * ch - self.H / 2) / half).astype(f32)
        self.U0 = np.ascontiguousarray(np.broadcast_to(xs, (R, C)))
        self.V0 = np.ascontiguousarray(np.broadcast_to(ys[:, None], (R, C)))
        self.vig = np.clip(1.15 - 0.55 * (self.U0 ** 2 + self.V0 ** 2), 0.15, 1).astype(f32)
        self.rr = np.arange(R)[:, None]
        rng = self.rng = np.random.default_rng()
        self.spd = (6 + 22 * rng.random(C)).astype(f32)
        self.ph = (rng.random(C) * (R + 40)).astype(f32)
        self.ln = (8 + rng.random(C) * 28).astype(f32)
        self.colamp = ((rng.random(C) < 0.80) * (0.55 + 0.45 * rng.random(C))).astype(f32)
        self.cph = (rng.random(C) * 9).astype(f32)
        self.H0 = rng.integers(0, NGLY, (R, C))
        self.RJ = rng.random((R, C)).astype(f32)
        self.RJ2 = rng.random((R, C)).astype(f32)
        self.sk_cr = int((self.SK_TOP + 0.55 * self.SK - self.v0) / self.dv)
        self._build_hud()
        self.dyn_log = []
        self.next_log = 0.0

    # ---- static HUD: corner brackets ----
    def _build_hud(self):
        R, C = self.rows, self.cols
        fc = np.zeros((R, C), np.uint8)
        fm = np.zeros((R, C), bool)
        bl, bh = max(8, C // 12), max(3, R // 14)

        def put(r, c, s):
            if 0 <= r < R and 0 <= c < C:
                fc[r, c] = ord(s)
                fm[r, c] = True

        for (r, c, sr, sc) in ((1, 1, 1, 1), (1, C - 2, 1, -1), (R - 2, 1, -1, 1), (R - 2, C - 2, -1, -1)):
            put(r, c, "+")
            for i in range(1, bl):
                put(r, c + sc * i, "=")
            for i in range(1, bh):
                put(r + sr * i, c, "|")
        self.frame_c, self.frame_m = fc, fm

    def _put(self, tc, tm, ti, r, c, s, inten):
        if r < 0 or r >= self.rows:
            return
        c0, c1 = max(c, 0), min(c + len(s), self.cols)
        if c1 <= c0:
            return
        seg = np.frombuffer(s.encode("ascii", "replace"), np.uint8)[c0 - c:c1 - c]
        tc[r, c0:c1] = seg
        tm[r, c0:c1] = True
        ti[r, c0:c1] = inten

    @staticmethod
    def _logline():
        k = random.randrange(8)
        ip = "%d.%d.%d.%d" % (random.randrange(1, 255), random.randrange(256), random.randrange(256), random.randrange(1, 255))
        return [
            "scan %s open" % ip, "inject 0x%06X ok" % random.randrange(1 << 24),
            "bypass node %03d" % random.randrange(1000),
            "render frame +%05d" % random.randrange(100000),
            "tunnel -> %s" % ip, "ping %dms" % random.randrange(8, 90),
            "uplink %d%%" % random.randrange(60, 100),
            "root@node%02d:~# _" % random.randrange(64),
        ][k]

    # ---- the hood ring that frames the whole scene ----
    def _hood(self, t, d):
        x, y = self.U0, self.V0
        cx, cy = 0.0, -0.06
        rad = np.hypot(x - cx, y - cy)
        R_out, R_in = 1.06, 0.97           # ring thickness
        wobble = 0.01 * sin(t * 0.6)
        ring = (rad > R_in + wobble) & (rad < R_out + wobble)
        # soften the bottom of the ring where shoulders break through
        open_bottom = (y > 0.55) & (np.abs(x) < 0.62)
        ring &= ~open_bottom
        glow = np.exp(-((rad - (R_in + R_out) / 2) / 0.05) ** 2) * (~open_bottom)
        return ring, glow, rad

    # ---- shoulders / hood fabric below the skull ----
    def _shoulders(self, t, d):
        x, y = self.U0, self.V0
        yy = y - 0.02 * sin(t * 0.8)
        # two sloped shoulder slabs meeting under the chin, widening toward the frame edge
        left = (x < 0) & (yy > 0.62 + 0.55 * (-x)) & (yy < 1.3) & (np.abs(x) < 0.95)
        right = (x >= 0) & (yy > 0.62 + 0.55 * (x)) & (yy < 1.3) & (np.abs(x) < 0.95)
        shoulders = left | right
        fold = (np.sin(x * 22 + y * 4) > 0.75) & shoulders        # fabric fold lines
        return shoulders, fold

    # ---- the skull (adapted from dedsec.py) ----
    def _skull(self, t, d):
        SK = self.SK * (1 + 0.008 * sin(t * 1.3))
        top = self.SK_TOP + 0.012 * sin(t * 1.1)
        x = self.U0 / SK
        y = (self.V0 - top) / SK
        ax = np.abs(x)
        cran = ((x / 0.47) ** 2 + ((y - 0.42) / 0.43) ** 2 < 1.0) & (y < 0.74)
        hw = 0.40 - 0.16 * np.clip((y - 0.55) / 0.43, 0, 1)
        face = (y > 0.55) & (y < 0.98) & (ax < hw)
        cheek = ((ax - 0.33) / 0.10) ** 2 + ((y - 0.64) / 0.075) ** 2 < 1.0
        upper = cran | face | cheek
        xr = ax - 0.22
        yr = (y - 0.50) + 0.5 * (ax - 0.22)
        sock = (np.abs(xr / 0.16) ** 2.6 + np.abs(yr / 0.115) ** 2.6) < 1.0
        nose = (y > 0.66) & (y < 0.80) & (ax < 0.07 * (y - 0.66) / 0.14 + 0.012)
        gap = np.mod(x / 0.066 + 0.5, 1.0) < 0.20
        teeth = (y > 0.98) & (y < 1.13) & (ax < 0.22 - 0.05 * (y - 0.98) / 0.15) & ~gap
        upper = (upper & ~sock & ~nose) | teeth
        jdy = 0.02 + 0.03 * (0.5 + 0.5 * sin(t * 1.7)) + d.jaw
        yj = y - jdy
        hwj = 0.25 - 0.13 * np.clip((yj - 1.20) / 0.36, 0, 1) ** 1.1
        jaw = (yj > 1.20) & (yj < 1.56) & (ax < hwj) & ~((yj < 1.32) & gap)
        pd = np.clip((yj - 1.28) / 0.30, 0, 1)
        rjt = np.roll(self.RJ, int(t * 7), axis=0)
        jaw &= rjt > (pd ** 1.3) * (0.55 + 0.45 * (0.5 + 0.5 * sin(t * 2.3)))
        mask = upper | jaw
        vis = (y < d.sk_scan) & (np.roll(self.RJ2, int(t * 9), axis=0) > d.dissolve)
        mask &= vis
        scan_line = (np.abs(y - d.sk_scan) < 0.03) & (ax < 0.62) & (d.sk_scan < 1.60) & (d.sk_scan > -0.1)
        light = (0.50 + 0.32 * np.exp(-(((x + 0.15) / 0.33) ** 2 + ((y - 0.28) / 0.36) ** 2))
                 + 0.10 * np.exp(-(((x - 0.2) / 0.2) ** 2 + ((y - 0.85) / 0.2) ** 2)))
        S = light * (0.88 + 0.12 * np.sin(y * 40 - t * 3))
        soft = blur(mask.astype(f32))
        rim = mask & (soft < 0.80)
        sg = blur((sock | nose).astype(f32))
        ring = mask & (sg > 0.12)
        S = np.where(ring, 0.85, np.where(rim, 1.0, S))
        S = np.where(mask, S, 0.0)
        ret = np.zeros(mask.shape, f32)
        rcode = np.zeros(mask.shape, np.uint8)
        eyevis = sock & vis
        sc = np.sin(y * 60 - t * 6)
        ret = np.where(eyevis, 0.10 * (0.5 + 0.5 * sc), ret)
        for sgn in (-1.0, 1.0):
            ex = sgn * 0.22 + d.gx * 0.05
            ey = 0.50 + d.gy * 0.04
            r = np.hypot(x - ex, y - ey)
            ringm = np.exp(-((r - 0.075) / 0.016) ** 2)
            cross = (((np.abs(x - ex) < 0.012) | (np.abs(y - ey) < 0.012)) & (r < 0.125) & (r > 0.03))
            dot = r < 0.022
            ticks = (np.sin(np.arctan2(y - ey, x - ex) * 8 + t * 1.5) > 0.88) & (np.abs(r - 0.108) < 0.012)
            e = np.maximum(np.maximum(ringm, cross * 0.9), np.maximum(dot * 1.0, ticks * 0.8)) * (0.80 + 0.20 * sin(t * 17 + sgn))
            m = eyevis & (e > 0.10)
            ret = np.where(m, np.maximum(ret, e), ret)
            rcode = np.where(m & (ringm > 0.3), ord("O"), rcode)
            rcode = np.where(m & cross, ord("+"), rcode)
            rcode = np.where(m & ticks, ord("|"), rcode)
            rcode = np.where(m & dot, ord("@"), rcode)
        return mask, rim, ring, S, soft, ret, rcode, scan_line, eyevis

    # ---- one frame ----
    def render(self, t, d):
        R, C = self.rows, self.cols
        rng = self.rng

        head = np.mod(t * self.spd + self.ph, R + self.ln)
        dist = head[None, :] - self.rr
        tail = (dist >= 0) & (dist < self.ln[None, :])
        Ir = np.where(tail, np.clip(1 - dist / self.ln[None, :], 0, 1) ** 1.5, 0.0) * 0.62
        Ir = np.where(tail & (dist < 1.0), 0.97, Ir) * self.colamp[None, :] * d.rain
        gi = (self.H0 + (t * 9.0 + self.cph).astype(np.int32)[None, :]) % NGLY
        code = GLY[gi]

        mask, rim, ring, S, soft, ret, rcode, scan_line, eyevis = self._skull(t, d)
        I = Ir * (1 - np.clip(soft * 1.5, 0, 1) * 0.93)

        # hood ring
        if d.hood > 0.01:
            hring, hglow, rad = self._hood(t, d)
            hcode = np.where((np.sin(rad * 90 - t * 2) > 0), ord("="), ord("-"))
            Ih = np.where(hring, 0.9, hglow * 0.35) * d.hood
            better = (Ih > I) & ~mask
            I = np.where(better, Ih, I)
            code = np.where(better, hcode, code)

        # shoulders / fabric
        if d.shoulders > 0.01:
            sh, fold = self._shoulders(t, d)
            Ish = np.where(fold, 0.55, 0.22) * d.shoulders
            shcode = np.where(fold, ord("/"), GLY[gi])
            better = sh & (Ish > I) & ~mask
            I = np.where(better, Ish, I)
            code = np.where(better & fold, shcode, code)

        # radar ping
        rad2 = np.hypot(self.U0, (self.V0 - (self.SK_TOP + 0.55 * self.SK)) * 1.0)
        rp = (t * 0.45) % 1.7
        Ip = 0.38 * np.exp(-((rad2 - rp) / 0.020) ** 2) * d.hood
        I = np.where((Ip > I) & ~mask, Ip, I)

        # skull on top
        glyph = np.where(((self.H0 + int(t * 2.5)) & 1) == 0, ord("0"), ord("1"))
        code = np.where(mask, glyph, code)
        I = np.where(mask, S, I)
        code = np.where(rim, np.where(S > 0.95, ord("@"), ord("#")), code)
        code = np.where(ring, ord("%"), code)
        I = np.where(eyevis, np.maximum(ret, np.where(eyevis, 0.05, 0)), I)
        code = np.where(ret > 0.15, np.where(rcode > 0, rcode, ord(":")), code)
        I = np.where(scan_line, 1.0, I)
        code = np.where(scan_line, ord("="), code)

        # text overlays (HUD corners + log + label)
        tc = np.zeros((R, C), np.uint8)
        tm_ = np.zeros((R, C), bool)
        ti = np.zeros((R, C), f32)
        hud = d.hud
        if hud > 0.01:
            fm = self.frame_m
            tc[fm] = self.frame_c[fm]
            tm_ |= fm
            ti[fm] = 0.55 * hud
            self._put(tc, tm_, ti, 1, 3, "DEDSEC :: HOOD", 0.9 * hud)
            s = "[ %s ]" % d.stage.upper()
            self._put(tc, tm_, ti, 1, C - 3 - len(s), s, 0.9 * hud)
            if d.stage != "boot" and t >= self.next_log:
                self.dyn_log.append(self._logline())
                self.dyn_log = self.dyn_log[-6:]
                self.next_log = t + random.uniform(0.3, 0.9)
            for i, s in enumerate(self.dyn_log):
                self._put(tc, tm_, ti, R - 2 - (len(self.dyn_log) - i), 3, s, 0.55 * hud)
        if d.term > 0.01:
            lines = self.typed_lines(d.boot_n)
            r0 = R // 2 - len(lines) // 2 - 1
            for i, s in enumerate(lines):
                cur = "_" if (i == len(lines) - 1 and int(t * 3) % 2 == 0 and d.boot_n < BOOT_TOTAL) else ""
                self._put(tc, tm_, ti, r0 + i, (C - len(s)) // 2, s + cur, 0.9 * d.term)
        if d.alert > 0.2 and int(t * 4) % 2 == 0:
            s = "!! TRACE DETECTED !!"
            self._put(tc, tm_, ti, 3, (C - len(s)) // 2, s, 1.0)
        I = np.where(tm_, ti, I)
        code = np.where(tm_, tc, code)

        # CRT post
        I = I + 0.40 * blur(np.clip(I - 0.60, 0, None))
        I = I * np.where((np.arange(R) & 1)[:, None] == 1, 0.86, 1.0)
        bar = ((t * 0.17) % 2.6) - 1.3
        I = I + 0.10 * np.exp(-((self.V0 - bar) / 0.06) ** 2)
        I = I * (0.96 + 0.04 * sin(t * 57) + 0.02 * random.random())
        I = I * self.vig
        acc = np.zeros((R, C), np.int8)

        g = d.glitch
        if g > 0.10:
            gs = int(2 + 5 * g)
            cy = np.roll(rim, -gs, axis=1) & ~rim & ~tm_
            mg = np.roll(rim, gs, axis=1) & ~rim & ~cy & ~tm_
            I = np.where(cy | mg, np.maximum(I, 0.85), I)
            code = np.where(cy | mg, ord("%"), code)
            acc[cy] = 1
            acc[mg] = 2
        if g > 0.02:
            for _ in range(int(1 + g * 9)):
                r0 = int(rng.integers(0, R))
                r1 = min(R, r0 + int(rng.integers(1, 2 + int(5 * g))))
                sh = int(rng.integers(-1, 2)) * int(rng.integers(2, 6 + int(26 * g)))
                if sh:
                    I[r0:r1] = np.roll(I[r0:r1], sh, axis=1)
                    code[r0:r1] = np.roll(code[r0:r1], sh, axis=1)
                    acc[r0:r1] = np.roll(acc[r0:r1], sh, axis=1)
            if g > 0.45:
                for _ in range(int(g * 4)):
                    h_, w_ = int(rng.integers(2, 7)), int(rng.integers(8, 32))
                    r0, c0 = int(rng.integers(0, R - h_)), int(rng.integers(0, C - w_))
                    I[r0:r0 + h_, c0:c0 + w_] = 0.3 + 0.7 * rng.random((h_, w_)).astype(f32)
                    code[r0:r0 + h_, c0:c0 + w_] = GLY[rng.integers(0, NGLY, (h_, w_))]
                    if rng.random() < 0.35:
                        acc[r0:r0 + h_, c0:c0 + w_] = 3
        j = rng.integers(0, R * C, 12)
        I.reshape(-1)[j] = np.maximum(I.reshape(-1)[j], 0.14)

        ci = np.clip((I * NG1).astype(np.int32), 0, NG1)
        ci = np.where(acc > 0, NG1 + acc.astype(np.int32), ci)
        code = code.astype(np.uint8)

        out = [None] * NLAYER
        for k in range(MIN_LEVEL, NLAYER):
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
            text = "\n".join([ln.rstrip() for ln in text.split("\n")])
            out[k] = (text, c0, r0)
        return out

    @staticmethod
    def typed_lines(n):
        out, left = [], n
        for s in BOOT:
            if left <= 0:
                break
            out.append(s[:left])
            left -= len(s) + 1
        return out


# ----------------------------------------------------------------------------
# Director
# ----------------------------------------------------------------------------
class Director:
    def __init__(self, t):
        self.t0 = t
        self.mouse = None
        self.mouse_t = -99.0
        self.dt = 0.016
        self.gx = self.gy = self.tx = self.ty = 0.0
        self.next_sacc = t + 1.0
        self.reset(t)

    def reset(self, t):
        self.stage, self.ts, self.dur = "boot", t, BOOT_DUR
        self.boot_n = 0
        self.rain = 0.0
        self.hud = 0.0
        self.term = 1.0
        self.sk_scan = -0.3
        self.dissolve = 0.0
        self.hood = 0.0
        self.shoulders = 0.0
        self.jaw = 0.0
        self.glitch = 0.0
        self.hue = 0.0
        self.flash = 0.0
        self.shake = 0.0
        self.alert = 0.0
        self.alert_ts = None
        self.next_alert = 1e18
        self.burst_amp = 0.0
        self.burst_end = -1.0
        self.next_burst = t + 3.0

    def _go(self, stage, t, dur):
        self.stage, self.ts, self.dur = stage, t, dur

    def burst(self, t, amp=1.0, length=0.5):
        self.burst_amp, self.burst_end = amp, t + length

    def toggle_alert(self, t):
        if self.stage == "live":
            self.alert_ts = None if self.alert_ts is not None else t

    def update(self, t, dt):
        self.dt = dt
        p = (t - self.ts) / self.dur
        st = self.stage
        base_glitch = 0.03
        if st == "boot":
            self.boot_n = int(min(1.0, p / 0.78) * BOOT_TOTAL)
            self.rain = 0.95 * smooth((p - 0.12) / 0.6)
            self.hud = smooth((p - 0.55) / 0.4)
            self.term, self.sk_scan = 1.0, -0.3
            self.hood, self.shoulders = 0.0, 0.0
            if p >= 1:
                self._go("assemble", t, ASSEMBLE_DUR)
                self.burst(t, 0.9, 0.35)
        elif st == "assemble":
            self.boot_n = BOOT_TOTAL
            self.rain, self.hud = 0.95, 1.0
            self.sk_scan = -0.2 + 1.95 * smooth(p / 0.75)
            self.term = 1 - smooth(p * 2.2)
            self.hood = smooth((p - 0.35) / 0.45)
            self.shoulders = smooth((p - 0.55) / 0.42)
            base_glitch = 0.35 * (1 - p) + 0.05
            if p >= 1:
                self._go("live", t, random.uniform(26, 34))
                self.next_alert = t + random.uniform(9, 14)
        elif st == "live":
            self.sk_scan, self.hood, self.shoulders, self.term = 1.8, 1.0, 1.0, 0.0
            self.rain, self.hud = 0.95, 1.0
            self.jaw = 0.012 * max(0.0, sin(t * 0.9)) ** 2
            if self.alert_ts is None and t >= self.next_alert:
                self.alert_ts = t
            if p >= 1:
                self.alert_ts = None
                self._go("purge", t, PURGE_DUR)
        elif st == "purge":
            e = smooth(p)
            self.dissolve = e
            self.hood = 1 - smooth(p * 1.5)
            self.hud = 1 - smooth(p * 1.2)
            self.shoulders = 1 - e
            self.rain = 0.95 + 0.05 * p
            self.jaw = 0.05 * e
            base_glitch = 0.15 + 0.5 * e
            if p >= 1:
                self.reset(t)
                return
        if self.alert_ts is not None and st == "live":
            ap = (t - self.alert_ts) / 5.0
            if ap >= 1:
                self.alert_ts = None
                self.next_alert = t + random.uniform(10, 16)
                self.alert = 0.0
            else:
                self.alert = sin(PI * ap) ** 0.7
        else:
            self.alert *= 0.90
        self.hue += (min(1.0, self.alert * 1.4) - self.hue) * (1 - exp(-6 * dt))
        self.flash = 0.30 * self.alert * max(0.0, sin(t * 9))
        if st == "live" and t >= self.next_burst:
            self.burst(t, random.uniform(0.35, 1.0), random.uniform(0.12, 0.45))
            self.next_burst = t + random.uniform(1.5, 4.5)
        env = self.burst_amp * (0.6 + 0.4 * random.random()) if t < self.burst_end else 0.0
        self.glitch = max(base_glitch, env, 0.55 * self.alert)
        self.shake = max(self.alert * 0.9, env * 0.5)
        k = 9.0
        if self.mouse and t - self.mouse_t < 2.5:
            self.tx, self.ty = self.mouse[0], self.mouse[1]
        elif t >= self.next_sacc:
            self.tx, self.ty = random.uniform(-1, 1), random.uniform(-0.8, 0.8)
            self.next_sacc = t + random.uniform(1.0, 2.8)
        self.gx += (self.tx - self.gx) * (1 - exp(-k * dt))
        self.gy += (self.ty - self.gy) * (1 - exp(-k * dt))

    def label(self):
        return self.stage.upper() + (" / ALERT" if self.alert > 0.3 else "")


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

        root.bind("<space>", lambda e: self.dir.burst(self.now(), 1.0, 0.55))
        root.bind("a", lambda e: self.dir.toggle_alert(self.now()))
        root.bind("r", lambda e: self.dir.reset(self.now()))
        root.bind("<Escape>", lambda e: root.destroy())
        root.bind("q", lambda e: root.destroy())
        root.bind("<plus>", lambda e: self.build(min(len(DETAIL) - 1, self.level + 1)))
        root.bind("<equal>", lambda e: self.build(min(len(DETAIL) - 1, self.level + 1)))
        root.bind("<minus>", lambda e: self.build(max(0, self.level - 1)))
        root.bind("<Motion>", self.on_motion)
        root.focus_force()
        self.tick()

    def build(self, level):
        self.level = level
        cols = DETAIL[level]
        root = self.root
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        for px in range(18, 5, -1):
            font = tkfont.Font(family=self.fam, size=-px)
            cw, chh = font.measure("M"), font.metrics("linespace")
            rows = round(cols * cw / chh)
            if cols * cw <= sw - 60 and rows * chh <= sh - 130:
                break
        self.font = font
        self.scene = Scene(cols, cw, chh)
        self.cv.delete("all")
        self.cv.config(width=self.scene.W, height=self.scene.H)
        pal = make_palette(0.0, 0.0)
        self.items = [None] * NLAYER
        for k in range(MIN_LEVEL, NLAYER):
            self.items[k] = self.cv.create_text(0, 0, anchor="nw", font=font, text="",
                                                fill="#%02x%02x%02x" % pal[k])
        self.pal_key = (0.0, 0.0)
        self.prev_text = [""] * NLAYER
        self.prev_pos = [None] * NLAYER
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

        cv, cw, ch = self.cv, self.scene.cw, self.scene.ch
        key = (round(d.hue, 2), round(d.flash, 2))
        if key != self.pal_key:
            pal = make_palette(d.hue, d.flash)
            for k in range(MIN_LEVEL, NG):
                cv.itemconfigure(self.items[k], fill="#%02x%02x%02x" % pal[k])
            self.pal_key = key
        sx = sy = 0
        if d.shake > 0.02:
            m = int(1 + 3 * d.shake)
            sx, sy = random.randint(-m, m), random.randint(-m, m)
        prev_text, prev_pos, items = self.prev_text, self.prev_pos, self.items
        for k in range(MIN_LEVEL, NLAYER):
            e = layers[k]
            if e is None:
                if prev_text[k]:
                    cv.itemconfigure(items[k], text="")
                    prev_text[k] = ""
                continue
            if e[0] != prev_text[k]:
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
            self.status.config(text="%s  |  SPACE glitch  |  A alert  |  R reboot  |  mouse = gaze  |  +/- detail %dx%d  |  ESC quit  |  %d fps"
                               % (d.label(), self.scene.cols, self.scene.rows, self.fps))
        if self.level > 0 and s - self.built_at > 6.0 and self.fps < AUTO_DOWNGRADE_FPS:
            self.build(self.level - 1)
            self.fps = 30.0
        el = time.perf_counter() - s
        self.root.after(max(1, int(1000 / TARGET_FPS - el * 1000)), self.tick)


if __name__ == "__main__":
    App().root.mainloop()
