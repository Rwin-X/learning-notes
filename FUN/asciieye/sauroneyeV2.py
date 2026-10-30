#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
THE EYE v2 — چشم سائورون، ASCII سینمایی با جزئیات بالا و FPS بالا

نصب:    pip install numpy          (tkinter همراه پایتون است)
اجرا:   python sauron_eye_v2.py

کنترل:  SPACE = بیدار/خواب      ماوس = چشم تو را دنبال می‌کند
        + / -  = جزئیات بیشتر/کمتر (شبکه‌ی کاراکتری)     T = برج تاریک روشن/خاموش
        ESC / Q = خروج
اگر FPS زیر ۲۴ بیاید برنامه خودش یک پله جزئیات را کم می‌کند.
"""
import math
import random
import sys
import time

try:
    import numpy as np
except ImportError:
    sys.exit("این برنامه به numpy نیاز دارد:  pip install numpy")
import tkinter as tk
import tkinter.font as tkfont

DETAIL = [96, 120, 144, 168, 192]   # تعداد ستون‌های کاراکتری در هر پله‌ی جزئیات
START_LEVEL = 2
TARGET_FPS = 60
NPAL = 18                           # تعداد سطح‌های رنگ (هر سطح یک لایه‌ی canvas)
NP1 = NPAL - 1
RAMP = " .'`,:;~-+=*xoX%#&@"
LM = len(RAMP) - 1
RAMPC = np.frombuffer(RAMP.encode(), np.uint8)
TIPC = np.frombuffer(b"^'\"~", np.uint8)
DIRC = np.frombuffer(b"-\\|/", np.uint8)
f32 = np.float32
sin, cos, exp = math.sin, math.cos, math.exp
PI = math.pi


def build_palette(n=NPAL):
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
    x = 0.0 if x < 0 else (1.0 if x > 1 else x)
    return x * x * x * (x * (6 * x - 15) + 10)


def blur(a):
    """بلوم ارزان: دو پاس جداپذیر."""
    for _ in range(2):
        p = a.copy()
        p[:, 1:] += 0.6 * a[:, :-1]
        p[:, :-1] += 0.6 * a[:, 1:]
        q = p.copy()
        q[1:] += 0.5 * p[:-1]
        q[:-1] += 0.5 * p[1:]
        a = q * 0.23
    return a


# ───────────────────────────── رندر (numpy) ─────────────────────────────
class Eye:
    A = 0.76                         # نیم‌عرض چشم بادامی
    IRX, IRY = 1 / 0.36, 1 / 0.41    # معکوس شعاع‌های عنبیه

    def __init__(self, cols, cw, ch):
        self.cols, self.cw, self.ch = cols, cw, ch
        R = self.rows = max(24, round(cols * cw / ch))
        self.W, self.H = cols * cw, R * ch
        half = self.half = self.W / 2.0
        xs = (((np.arange(cols) + 0.5) * cw - self.W / 2) / half).astype(f32)
        ys = (((np.arange(R) + 0.5) * ch - self.H / 2) / half).astype(f32)
        self.U0 = np.ascontiguousarray(np.broadcast_to(xs, (R, cols)))
        self.V0 = np.ascontiguousarray(np.broadcast_to(ys[:, None], (R, cols)))
        self.vig = np.clip(1.20 - 0.62 * (self.U0 ** 2 + self.V0 ** 2), 0, 1).astype(f32)
        self.BGF = (np.exp(-np.abs(self.V0) * 14.0) * np.exp(-np.abs(self.U0) * 1.1)).astype(f32)
        self.rng = np.random.default_rng()
        self._build_tower()
        self.E = np.zeros((0, 7), f32)
        self.acc = 0.0

    # ---- برج تاریک (سیلوئت) ----
    def _build_tower(self):
        U, V, rng = self.U0, self.V0, self.rng
        ridge = 0.80 + 0.05 * np.sin(U * 9 + 0.5) + 0.035 * np.sin(U * 23 + 1.0) + 0.018 * np.sin(U * 51 + 2.0)
        occl = V > ridge
        top = 0.54
        w = 0.011 + np.clip(V - top, 0, None) * 0.10 + 0.010 * (np.sin(V * 60) > 0.6)
        occl |= (V > top) & (np.abs(U) < w)
        occl |= (V > 0.47) & (V <= top) & (np.abs(U) < (V - 0.47) * 0.09)
        for cx, y0, k in [(-0.17, 0.62, 0.06), (0.17, 0.62, 0.06), (-0.31, 0.67, 0.07),
                          (0.31, 0.67, 0.07), (-0.45, 0.71, 0.08), (0.45, 0.71, 0.08)]:
            occl |= (V > y0) & (np.abs(U - cx) < 0.008 + (V - y0) * k)
        free = ~occl
        nb = np.zeros_like(occl)
        nb[1:] |= free[:-1]
        nb[:, 1:] |= free[:, :-1]
        nb[:, :-1] |= free[:, 1:]
        edge = occl & nb
        win = np.zeros_like(occl)
        for vv in (0.62, 0.70, 0.78, 0.86):
            r = int(np.argmin(np.abs(self.V0[:, 0] - vv)))
            c = self.cols // 2
            win[r, c] = True
        win &= occl
        ground = V > ridge
        lava = ground & ~edge & (rng.random(U.shape) < 0.03)
        self.occl, self.edge, self.win, self.lava = occl, edge, win & ~edge, lava
        self.tph = (rng.random(U.shape) * 6.28).astype(f32)

    # ---- جرقه‌ها ----
    def _embers(self, dt, fire, rage):
        self.acc += 90.0 * fire * (1 + rage) * dt
        k = int(self.acc)
        self.acc -= k
        E = self.E
        rng = self.rng
        if k > 0:
            ang = rng.random(k) * 6.2832
            rr = 0.25 + rng.random(k) * 0.55
            new = np.empty((k, 7), f32)
            new[:, 0] = np.cos(ang) * rr * 0.95
            new[:, 1] = np.sin(ang) * rr * 0.7
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

    def render(self, t, d, tower=True):
        R, C = self.rows, self.cols
        rng = self.rng
        A = self.A
        opn = d.open * d.blink
        rage, fire = d.rage, d.fire
        lx, ly = d.gx, d.gy

        # دوربین: نزدیک‌شدن آرام + لرزش
        z = 1.0 + 0.04 * min(d.open, 1.2) + 0.03 * rage + 0.012 * sin(t * 0.23)
        jx = jy = 0.0
        if d.shake > 0.02:
            jx = random.uniform(-1, 1) * 0.012 * d.shake
            jy = random.uniform(-1, 1) * 0.012 * d.shake
        u = self.U0 * (1.0 / z) + jx
        v = self.V0 * (1.0 / z) + jy
        th = np.arctan2(v, u)
        g = np.hypot(u * (1 / 1.25), v * (1 / 1.15))

        up_h, lo_h = 0.46 * opn, 0.36 * opn
        kc = 0.35 * opn
        rim_amp = 0.55 + 0.45 * min(1.0, opn * 3.0)
        pw = (0.030 + 0.008 * sin(t * 1.9) + 0.004 * sin(t * 5.3)) * (1 - 0.45 * rage)
        fl = 0.60 * fire * (0.4 + 0.6 * min(1.0, opn * 2.0))
        gl = (1.0 + 0.25 * rage) * (1.0 + 0.04 * sin(t * 8.3))
        fire_k = 0.45 + 0.65 * fire
        reach_k = 0.55 + 0.45 * fire

        # ── آتش: زبانه‌های چندلایه ──
        w1 = np.sin(th * 11 + 2.0 * np.sin(g * 7 - t * 3.2) - t * 1.7)
        w2 = np.sin(th * 17 - g * 9 + t * 2.6)
        w3 = np.sin(th * 29 + g * 13 - t * 4.1 + 1.7 * np.sin(th * 5 + t * 0.8))
        lobe = (0.5 + 0.5 * w1) ** 2
        reach = (0.50 + 0.80 * lobe * (0.80 + 0.20 * w2) + 0.10 * lobe * w3) * reach_k
        reach = reach * np.where(v < 0, 1 - 0.30 * v, 1.0)
        rg = reach - g
        F = np.where(rg > 0, np.clip(rg / reach, 0, 1) ** 0.9 * 0.95, 0.0)
        F = F * (0.80 + 0.20 * np.sin(v * 22 - t * 7 + 3 * np.sin(u * 11 + t)))
        I_out = F * fire_k + (0.38 * np.exp(-3.0 * g * g) + 0.08 * np.exp(-1.3 * g)) * fire
        # پرتوهای حجمی
        rad = np.hypot(u, v)
        rays = (0.5 + 0.5 * np.sin(th * 9 + t * 0.35 + 2 * np.sin(th * 3 - t * 0.2))) ** 4
        I_out = I_out + rays * np.exp(-1.6 * rad) * 0.14 * fire * (0.3 + 0.7 * min(1.0, opn))

        # ── هندسه‌ی پلک ──
        x = u * (1 / A)
        t1 = np.clip(1 - x * x, 0, None)
        in_u = np.abs(u) < A
        s = np.where(in_u, t1 ** 0.85, 0.0)
        sl = np.where(in_u, np.abs(0.85 * np.maximum(t1, 1e-3) ** -0.15 * 2 * x / A), 0.0)
        du = v + up_h * s
        dl = lo_h * s - v
        inside = in_u & (du > 0) & (dl > 0)
        corr = 1.0 / (1.0 + kc * sl)
        m = np.minimum(du, dl) * corr
        dd = np.where(in_u, np.where(du < 0, -du, -dl) * corr, np.hypot(np.abs(u) - A, v))
        dd = np.maximum(dd, 0)

        # بیرون: سایه‌ی کاسه‌ی چشم، لبه‌ی درخشان، ترک‌های گدازه‌ای روی پلک
        tt = np.clip((dd - 0.02) * 11.0, 0, 1)
        I_out = I_out * (tt * tt * (3 - 2 * tt))
        lava = np.clip(np.sin(u * 37 + 3 * np.sin(v * 23 + t * 0.3)) * np.sin(v * 41 - 2 * np.sin(u * 17)), 0, 1) ** 3
        I_out = I_out + 0.30 * lava * np.exp(-dd * 9.0) * (dd > 0.03) * (0.5 + 0.5 * fire)
        I_out = I_out + rim_amp * np.exp(-dd * dd * 1100.0) + self.BGF * fl

        # ── درون چشم ──
        dx = u - lx
        dy = v - ly
        q = np.hypot(dx * self.IRX, dy * self.IRY)
        phi = np.arctan2(dy, dx)
        fib = 0.5 + 0.5 * np.sin(phi * 34 + 2.5 * np.sin(q * 8 - t * 1.1))
        fib2 = 0.5 + 0.5 * np.sin(phi * 91 + 4.0 * np.sin(q * 17 + t * 0.7))
        crypt = np.sin(phi * 7 + q * 12) * np.sin(phi * 5 - q * 9 + t * 0.5)
        Ii = (0.80 - 0.40 * q + 0.20 * (fib - 0.5) + 0.10 * (fib2 - 0.5)
              + 0.12 * np.exp(-((q - 0.45) / 0.05) ** 2) - 0.10 * np.clip(crypt - 0.3, 0, None))
        Ii = Ii * np.where(q > 0.84, 0.62 + 0.38 * (1 - q) * 6.25, 1.0)
        # مردمک شکافی (نوک‌تیز)
        ph = 0.37
        ty = np.clip(1 - (dy / ph) ** 2, 0, 1)
        pn = np.abs(dx) / (pw * np.maximum(ty, 1e-3) ** 0.75)
        pup = (np.abs(dy) < ph) & (pn < 1)
        glow = np.clip(1 - (pn - 1) / 2.2, 0, 1) * (np.abs(dy) < ph * 1.03)
        Ii = Ii + 0.65 * glow * (~pup)
        iris = q < 1.0
        # صلبیه‌ی آتشین: رگه‌ها + هاله دور عنبیه
        vein = (0.5 + 0.5 * np.sin(phi * 23 + 3 * np.sin(q * 20))) ** 8 * 0.18
        scl = (0.16 + 0.26 * np.exp(-(u * u * 2.0 + v * v * 10.0)) + vein
               + 0.05 * np.sin(u * 23 + t * 1.3) * np.sin(v * 31 - t * 0.9))
        halo = 0.30 * np.exp(-(((q - 1) * 3) ** 2) * 2)
        I_in = np.where(iris, np.maximum(scl, Ii), scl + halo)
        spec = np.exp(-(((dx + 0.11) * 20) ** 2 + ((dy + 0.15) * 33) ** 2))
        I_in = I_in + 0.7 * spec * iris
        I_in = np.where(pup, 0.08 * (0.5 + 0.5 * np.sin(dy * 50 - t * 3 + dx * 60)), I_in)
        sh = np.clip(m * 7.7, 0, 1)
        I_in = I_in * (0.35 + 0.65 * sh * (2 - sh)) * gl + rim_amp * np.exp(-m * m * 1100.0)

        I = np.where(inside, I_in, I_out)

        # بلوم + ویگنت
        I = I + 0.45 * blur(np.clip(I - 0.55, 0, None))
        I = I * self.vig

        # برج تاریک و نور لبه‌اش
        if tower:
            fk = 0.4 + 0.6 * fire
            tl = (self.edge * (0.30 + 0.25 * fire)
                  + self.win * (0.55 + 0.45 * np.sin(t * 2.7 + self.tph)) * 0.9
                  + self.lava * (0.20 + 0.25 * np.sin(t * 1.9 + self.tph * 3))) * fk
            I = np.where(self.occl, tl, I)

        ci = np.clip((I * NP1).astype(np.int32), 0, NP1)

        # ── کاراکترها ──
        rn = rng.random((R, C), dtype=f32)
        li_o = np.clip((I * LM + rn - 0.35).astype(np.int32), 0, LM)
        li_i = np.clip((I * LM).astype(np.int32), 0, LM)
        codes = np.where(inside, RAMPC[li_i], RAMPC[li_o])
        tip = (rg > 0) & (rg < 0.07) & (~inside) & (I > 0.10) & (rn > 0.45)
        codes = np.where(tip, TIPC[(rn * 40).astype(np.int32) & 3], codes)
        dirm = inside & iris & (~pup) & (Ii > 0.20) & (Ii < 0.95) & (((rn * 13.7) % 1.0) < 0.62)
        dirc = DIRC[(np.mod(phi, PI) / PI * 4 + 0.5).astype(np.int32) & 3]
        codes = np.where(dirm, dirc, codes).astype(np.uint8)

        # جرقه‌ها
        self._embers(d.dt, fire, rage)
        E = self.E
        cif, cof = ci.reshape(-1), codes.reshape(-1)
        if len(E):
            half = self.half
            c = ((E[:, 0] * half + self.W / 2) / self.cw).astype(np.int32)
            r = ((E[:, 1] * half + self.H / 2) / self.ch).astype(np.int32)
            ok = (c >= 0) & (c < C) & (r >= 0) & (r < R)
            Ie = (1 - E[:, 4] / E[:, 5]) * (0.62 + 0.38 * np.sin(E[:, 4] * 18 + E[:, 6]))
            ok &= Ie > 0.12
            idx, Ie = r[ok] * C + c[ok], Ie[ok]
            if tower:
                fr = ~self.occl.reshape(-1)[idx]
                idx, Ie = idx[fr], Ie[fr]
            cie = np.clip((Ie * NP1).astype(np.int32), 0, NP1)
            mk = cie > cif[idx]
            cif[idx[mk]] = cie[mk]
            cof[idx[mk]] = np.where(Ie > 0.7, 42, np.where(Ie > 0.5, 43, np.where(Ie > 0.3, 39, 46)))[mk]
        # دانه‌ی فیلم
        j = rng.integers(0, R * C, 14)
        j = j[cif[j] == 0]
        cif[j] = 3
        cof[j] = 46

        # لایه‌ها: هر سطح رنگ یک متن؛ فقط ناحیه‌ی پوشش‌دهنده‌اش
        out = [None] * NPAL
        for k in range(1, NPAL):
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
            blk[:, :-1] = np.where(sub[:, c0:c1 + 1], codes[r0:r1 + 1, c0:c1 + 1], 32)
            out[k] = (blk.tobytes()[:-1].decode("ascii"), c0, r0)
        return out


# ───────────────────────────── کارگردان ─────────────────────────────
class Director:
    def __init__(self, t):
        self.state = "sleep"; self.ts = t; self.dur = 1.8
        self.open = 0.0; self.open0 = 0.0
        self.fire = 0.14; self.fire0 = 0.14
        self.rage = 0.0; self.rage_ts = None; self.rage_dur = 5.0
        self.next_rage = 1e18
        self.blink = 1.0; self.blink_ts = -9.0; self.blink_dur = 0.42
        self.next_blink = 1e18
        self.gx = self.gy = self.tx = self.ty = 0.0
        self.next_sacc = t + 2.0
        self.mode = "idle"; self.mode_ts = t; self.next_sweep = t + 10.0
        self.mouse = None; self.mouse_t = -99.0
        self.dt = 0.016
        self.shake = 0.0

    def _go(self, state, t, dur):
        self.state, self.ts, self.dur = state, t, dur
        self.open0, self.fire0 = self.open, self.fire

    def toggle(self, t):
        if self.state in ("opening", "awake"):
            self._go("closing", t, 0.8 + 2.6 * self.open)
        else:
            self._go("opening", t, 0.8 + 4.2 * (1 - self.open))

    def update(self, t, dt):
        self.dt = dt
        p = (t - self.ts) / self.dur
        st = self.state
        if st == "sleep":
            self.open = 0.0
            self.fire = 0.14 + 0.04 * sin(t * 1.3)
            if p >= 1: self._go("opening", t, 5.0)
        elif st == "opening":
            e = smooth(p)
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
                    self.rage = 0.0; self.rage_ts = None
                    self.next_rage = t + random.uniform(9, 16)
                else:
                    self.rage = sin(PI * rp) ** 1.4
            elif t >= self.next_rage:
                self.rage_ts = t
            if self.rage_ts is None and t >= self.next_blink:
                self.blink_ts = t
                self.next_blink = t + (0.7 if random.random() < 0.25 else random.uniform(6, 12))
            if p >= 1:
                self._go("closing", t, 3.4)
        elif st == "closing":
            e = smooth(p)
            self.open = self.open0 * (1 - e)
            self.fire = 0.14 + (self.fire0 - 0.14) * (1 - e)
            self.rage *= 0.97
            if p >= 1:
                self.rage = 0.0; self.rage_ts = None
                self._go("sleep", t, 2.2)

        if st != "awake":
            self.rage = 0.0 if st != "closing" else self.rage
        self.open += 0.13 * self.rage
        self.fire += 0.35 * self.rage
        self.shake = self.rage * self.rage

        pb = (t - self.blink_ts) / self.blink_dur
        self.blink = 1.0 - sin(PI * pb) ** 2 if 0.0 <= pb < 1.0 else 1.0

        k = 10.0
        if self.mouse and t - self.mouse_t < 2.5:
            self.tx, self.ty = self.mouse[0] * 0.18, self.mouse[1] * 0.05
            k = 7.0
        elif self.mode == "sweep":
            ph = (t - self.mode_ts) / 6.5
            if ph >= 1:
                self.mode = "idle"; self.next_sweep = t + random.uniform(12, 20)
            else:
                self.tx = 0.17 * sin(ph * 2 * PI); self.ty = 0.02 * sin(ph * 4 * PI); k = 3.0
        else:
            if t >= self.next_sacc:
                if random.random() < 0.45:
                    self.tx = random.gauss(0, 0.03); self.ty = random.gauss(0, 0.01)
                else:
                    self.tx = random.uniform(-0.17, 0.17); self.ty = random.uniform(-0.04, 0.04)
                self.next_sacc = t + random.uniform(1.1, 3.4)
            if st == "awake" and t >= self.next_sweep and self.rage_ts is None:
                self.mode, self.mode_ts = "sweep", t
            k = 11.0
        w = 1.0 - 0.85 * self.rage
        self.gx += (self.tx * w - self.gx) * (1 - exp(-k * dt))
        self.gy += (self.ty * w - self.gy) * (1 - exp(-k * dt))
        self.gx += 0.0015 * sin(t * 17.0)

    def label(self):
        return {"sleep": "SLEEPING", "opening": "AWAKENING", "closing": "CLOSING",
                "awake": "ENRAGED" if self.rage > 0.4 else "WATCHING"}[self.state]


# ───────────────────────────── GUI ─────────────────────────────
class App:
    def __init__(self):
        self.root = root = tk.Tk()
        root.title("THE EYE")
        root.configure(bg="#000000")
        root.resizable(False, False)
        avail = set(tkfont.families())
        self.fam = next((f for f in ("Cascadia Mono", "Consolas", "Menlo", "DejaVu Sans Mono",
                                     "Liberation Mono", "Courier New", "Courier") if f in avail), "Courier")
        self.cv = tk.Canvas(root, bg="#000000", highlightthickness=0, bd=0, cursor="arrow")
        self.cv.pack()
        self.status = tk.Label(root, text="", bg="#000000", fg="#5a1a0a", font=(self.fam, 9))
        self.status.pack(fill="x")
        self.tower = True
        self.t0 = time.perf_counter()
        self.last = self.t0
        self.dir = Director(0.0)
        self.fps = 30.0
        self.stat_t = 0.0
        self.build(START_LEVEL)

        root.bind("<space>", lambda e: self.dir.toggle(self.now()))
        root.bind("<Escape>", lambda e: root.destroy())
        root.bind("q", lambda e: root.destroy())
        root.bind("t", lambda e: setattr(self, "tower", not self.tower))
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
        self.eye = Eye(cols, cw, chh)
        self.cv.delete("all")
        self.cv.config(width=self.eye.W, height=self.eye.H)
        self.items = [None] + [
            self.cv.create_text(0, 0, anchor="nw", font=font, text="",
                                fill="#%02x%02x%02x" % PAL[k]) for k in range(1, NPAL)]
        self.shown = [False] * NPAL
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
        layers = self.eye.render(t, d, self.tower)
        cv, cw, ch = self.cv, self.eye.cw, self.eye.ch
        sx = sy = 0
        if d.shake > 0.02:
            m = int(1 + 3 * d.shake)
            sx, sy = random.randint(-m, m), random.randint(-m, m)
        for k in range(1, NPAL):
            e, it = layers[k], self.items[k]
            if e is None:
                if self.shown[k]:
                    cv.itemconfigure(it, text="")
                    self.shown[k] = False
            else:
                cv.itemconfigure(it, text=e[0])
                cv.coords(it, e[1] * cw + sx, e[2] * ch + sy)
                self.shown[k] = True
        cv.update_idletasks()

        self.fps = self.fps * 0.93 + (1.0 / max(dt, 1e-3)) * 0.07
        if t - self.stat_t > 0.5:
            self.stat_t = t
            self.status.config(text="%s  ·  SPACE wake/sleep  ·  mouse gaze  ·  +/- detail %dx%d  ·  T tower  ·  ESC  ·  %d fps"
                               % (d.label(), self.eye.cols, self.eye.rows, self.fps))
        # اگر کند بود، یک پله جزئیات را کم کن
        if self.level > 0 and s - self.built_at > 6.0 and self.fps < 24:
            self.build(self.level - 1)
            self.fps = 30.0
        el = time.perf_counter() - s
        self.root.after(max(1, int(1000 / TARGET_FPS - el * 1000)), self.tick)


if __name__ == "__main__":
    App().root.mainloop()
