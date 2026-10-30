#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
THE EYE — چشم سائورون به صورت ASCII art سینمایی (GUI با tkinter)

اجرا:   python sauron_eye.py
نیازمندی: Python 3.8+ ؛ فقط کتابخانه‌ی استاندارد (tkinter)، بدون نصب پکیج

کنترل:  SPACE = بیدار/خواب   |  ماوس = چشم تو را دنبال می‌کند   |  ESC / Q = خروج
اگر کند بود: COLS را کمتر کن (مثلاً 84).
"""
import math
import random
import time
import tkinter as tk
import tkinter.font as tkfont

COLS = 120            # عرض شبکه‌ی کاراکتری (ردیف‌ها خودکار از نسبت فونت محاسبه می‌شود)
TARGET_FPS = 30
RAMP = " .'`,:;~-+=*xoX%#&@"
LM = len(RAMP) - 1
NPAL = 40
NP1 = NPAL - 1

sin, cos, exp, sqrt, atan2, hypot = (math.sin, math.cos, math.exp, math.sqrt,
                                     math.atan2, math.hypot)
PI = math.pi


def build_palette(n=NPAL):
    stops = [(0.00, (0, 0, 0)), (0.10, (38, 0, 0)), (0.25, (108, 8, 0)),
             (0.42, (188, 34, 0)), (0.58, (236, 86, 0)), (0.74, (255, 152, 12)),
             (0.88, (255, 216, 94)), (1.00, (255, 249, 208))]
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
TAGS = ["c%d" % i for i in range(NPAL)]
RN = [random.random() for _ in range(8192)]


def smooth(x):
    x = 0.0 if x < 0 else (1.0 if x > 1 else x)
    return x * x * x * (x * (6 * x - 15) + 10)


# ───────────────────────────── رندر ─────────────────────────────
class Eye:
    A = 0.76                     # نیم‌عرض چشم (بادامی)
    IRX, IRY = 1 / 0.36, 1 / 0.41  # معکوس شعاع‌های عنبیه

    def __init__(self, cols, cw, ch):
        self.cols = cols
        self.rows = rows = max(24, round(cols * cw / ch))
        self.cw, self.ch = cw, ch
        self.W, self.H = cols * cw, rows * ch
        half = self.half = self.W / 2.0
        N = self.N = cols * rows
        a = self.A
        U, V, TH, GM, SH, SL, DST, SCL, CORE, BGF = ([] for _ in range(10))
        act, fars = [], []
        for r in range(rows):
            v = ((r + 0.5) * ch - self.H / 2) / half
            for c in range(cols):
                u = ((c + 0.5) * cw - self.W / 2) / half
                i = r * cols + c
                g = hypot(u / 1.25, v / 1.15)
                zone = abs(u) < a + 0.25 and abs(v) < 0.62
                if zone and abs(u) < a:
                    x = u / a
                    t1 = 1 - x * x
                    s = t1 ** 0.85
                    sl = abs(0.85 * t1 ** -0.15 * (-2 * x / a))
                    d = 9.0
                elif zone:
                    s, sl, d = -1.0, 0.0, hypot(abs(u) - a, v)
                else:
                    s, sl, d = -1.0, 0.0, 9.0
                bgf = exp(-abs(v) * 14.0) * exp(-abs(u) * 1.1)
                U.append(u); V.append(v); TH.append(atan2(v, u)); GM.append(g)
                SH.append(s); SL.append(sl); DST.append(d)
                SCL.append(0.16 + 0.26 * exp(-(u * u * 2.0 + v * v * 10.0)))
                CORE.append(0.38 * exp(-3.0 * g * g) + 0.08 * exp(-1.3 * g))
                BGF.append(bgf)
                if g < 1.1 or zone:
                    act.append(i)
                elif bgf > 0.04:
                    fars.append(i)
        self.U, self.V, self.TH, self.GM = U, V, TH, GM
        self.SH, self.SL, self.DST, self.SCL, self.CORE, self.BGF = SH, SL, DST, SCL, CORE, BGF
        self.act, self.fars = act, fars
        self.zero_ci = [0] * N
        self.blank = [" "] * N
        self.embers = []
        self.acc = 0.0
        self.fr = 0

    # ---- ذرات آتش ----
    def _embers(self, dt, fire, rage):
        self.acc += (55.0 * fire * (1 + rage)) * dt
        while self.acc >= 1.0:
            self.acc -= 1.0
            ang = random.random() * 2 * PI
            rr = 0.25 + random.random() * 0.55
            self.embers.append([cos(ang) * rr * 0.95, sin(ang) * rr * 0.7,
                                (random.random() - 0.5) * 0.08,
                                -(0.10 + 0.25 * random.random()),
                                0.0, 1.8 + 3.0 * random.random(),
                                random.random() * 6.28])
        keep = []
        for e in self.embers:
            e[4] += dt
            e[0] += e[2] * dt + 0.03 * sin(e[4] * 3 + e[6]) * dt
            e[1] += e[3] * dt
            if e[4] < e[5] and abs(e[0]) < 1.0 and abs(e[1]) < 1.0:
                keep.append(e)
        self.embers = keep

    def render(self, t, d):
        cols, rows, N = self.cols, self.rows, self.N
        U, V, TH, GM, SH, SL, DST = self.U, self.V, self.TH, self.GM, self.SH, self.SL, self.DST
        SCL, CORE, BGF = self.SCL, self.CORE, self.BGF
        CI = self.zero_ci[:]
        CH = self.blank[:]
        self.fr += 1
        fr = self.fr

        opn = d.open * d.blink
        rage, fire = d.rage, d.fire
        lx, ly = d.gx, d.gy
        up_h, lo_h = 0.46 * opn, 0.36 * opn
        kc = 0.35 * opn
        rim_amp = 0.55 + 0.45 * min(1.0, opn * 3.0)
        pw = (0.030 + 0.008 * sin(t * 1.9) + 0.004 * sin(t * 5.3)) * (1 - 0.45 * rage)
        pwi, phi_ = 1.0 / pw, 1.0 / 0.37
        fl = 0.60 * fire * (0.4 + 0.6 * min(1.0, opn * 2.0))
        gl = (1.0 + 0.25 * rage) * (1.0 + 0.04 * sin(t * 8.3))
        fire_k = 0.45 + 0.65 * fire
        reach_k = 0.55 + 0.45 * fire
        IRX, IRY = self.IRX, self.IRY
        RNl = RN

        for i in self.act:
            u = U[i]; v = V[i]
            s = SH[i]
            inside = False
            if s >= 0.0:
                up = up_h * s; lo = lo_h * s
                du = v + up; dl = lo - v
                if du > 0.0 and dl > 0.0:
                    inside = True
                    m = du if du < dl else dl
                    m /= (1.0 + kc * SL[i])
                else:
                    dd = -du if du < 0.0 else -dl
                    dd /= (1.0 + kc * SL[i])
            else:
                dd = DST[i]

            if inside:
                sh = m * 7.7
                if sh > 1.0: sh = 1.0
                shade = 0.35 + 0.65 * sh * (2.0 - sh)
                dx = u - lx; dy = v - ly
                qx = dx * IRX; qy = dy * IRY
                q2 = qx * qx + qy * qy
                I = SCL[i]
                ch = None
                if q2 < 1.0:
                    q = sqrt(q2)
                    phi = atan2(dy, dx)
                    fib = 0.5 + 0.5 * sin(phi * 34.0 + 2.5 * sin(q * 8.0 - t * 1.1))
                    Ii = 0.80 - 0.40 * q + 0.22 * (fib - 0.5)
                    if q > 0.84:
                        Ii *= 0.62 + 0.38 * (1.0 - q) * 6.25
                    px = dx * pwi; py = dy * phi_
                    pp = px * px + py * py
                    if pp < 1.0:
                        I = 0.0; ch = " "
                    else:
                        if pp < 3.5:
                            Ii += 0.65 * (1.0 - (pp - 1.0) * 0.4)
                        if Ii > I: I = Ii
                        if 0.20 < Ii < 0.95 and RNl[(i * 29 + fr * 3) & 8191] < 0.62:
                            ch = "-\\|/"[int(((phi % PI) / PI) * 4.0 + 0.5) & 3]
                        # جرقه‌ی نور روی عنبیه
                        sx = (dx + 0.11) * 20.0; sy = (dy + 0.15) * 33.0
                        I += 0.7 * exp(-(sx * sx + sy * sy))
                else:
                    # هاله‌ی آتشین اطراف عنبیه روی صلبیه
                    k = (sqrt(q2) - 1.0) * 3.0
                    if k < 1.5:
                        I += 0.30 * exp(-k * k * 2.0)
                I *= shade * gl
                if m < 0.06:
                    I += rim_amp * exp(-m * m * 1100.0)
                if ch is None:
                    li = int(I * LM)
                    ch = RAMP[LM if li > LM else (0 if li < 0 else li)]
                I_out = I
            else:
                g = GM[i]; th = TH[i]
                w1 = sin(th * 11.0 + 2.0 * sin(g * 7.0 - t * 3.2) - t * 1.7)
                w2 = sin(th * 17.0 - g * 9.0 + t * 2.6)
                lobe = 0.5 + 0.5 * w1
                reach = (0.50 + 0.80 * lobe * lobe * (0.80 + 0.20 * w2)) * reach_k
                if v < 0.0:
                    reach *= 1.0 - 0.30 * v
                rg = reach - g
                F = 0.0
                edge = False
                if rg > 0.0:
                    edge = rg < 0.07
                    F = (rg / reach) ** 0.9 * 0.95
                I = F * fire_k + CORE[i] * fire
                if dd < 0.11:
                    tt = (dd - 0.02) * 11.0
                    if tt < 0.0: tt = 0.0
                    elif tt > 1.0: tt = 1.0
                    I *= tt * tt * (3.0 - 2.0 * tt)
                    if dd < 0.07:
                        I += rim_amp * exp(-dd * dd * 1100.0)
                I += BGF[i] * fl
                I_out = I
                rn = RNl[(i * 13 + fr * 7) & 8191]
                if edge and I > 0.10 and rn > 0.45:
                    ch = "^'\"~"[int(rn * 40) & 3]
                else:
                    li = int(I * LM + rn - 0.35)
                    ch = RAMP[LM if li > LM else (0 if li < 0 else li)]

            ci = int(I_out * NP1)
            if ci > 0:
                CI[i] = NP1 if ci > NP1 else ci
                CH[i] = ch

        # خط نور افقیِ لنز (anamorphic) در بقیه‌ی سلول‌ها
        for i in self.fars:
            I = BGF[i] * fl
            ci = int(I * NP1)
            if ci > 1:
                CI[i] = ci
                li = int(I * LM)
                CH[i] = RAMP[li if li < LM else LM]

        # جرقه‌ها
        self._embers(d.dt, fire, rage)
        half, Wh, Hh, cw, chh = self.half, self.W / 2, self.H / 2, self.cw, self.ch
        for e in self.embers:
            c = int((e[0] * half + Wh) / cw)
            r = int((e[1] * half + Hh) / chh)
            if 0 <= c < cols and 0 <= r < rows:
                fade = 1.0 - e[4] / e[5]
                I = fade * (0.62 + 0.38 * sin(e[4] * 18 + e[6]))
                if I > 0.12:
                    ci = int(I * NP1)
                    idx = r * cols + c
                    if ci > CI[idx]:
                        CI[idx] = ci
                        CH[idx] = "*" if I > 0.7 else ("+" if I > 0.5 else ("'" if I > 0.3 else "."))

        # گرد و غبار / دانه‌ی فیلم
        for _ in range(8):
            j = random.randrange(N)
            if CI[j] == 0:
                CI[j] = random.randint(2, 5)
                CH[j] = "."

        # ساخت run های رنگی
        args = []
        for r in range(rows):
            b = r * cols
            cis = CI[b:b + cols]
            chs = CH[b:b + cols]
            start = 0
            cur = cis[0]
            for j in range(1, cols):
                c = cis[j]
                if c != cur:
                    args.append("".join(chs[start:j])); args.append(TAGS[cur])
                    start = j; cur = c
            tail = "".join(chs[start:cols])
            if r < rows - 1:
                tail += "\n"
            args.append(tail); args.append(TAGS[cur])
        return args


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
        self.dt = 0.033
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

        # نگاه
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
        fam = next((f for f in ("Cascadia Mono", "Consolas", "Menlo", "DejaVu Sans Mono",
                                "Liberation Mono", "Courier New", "Courier") if f in avail), "Courier")
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        for size in range(14, 5, -1):
            font = tkfont.Font(family=fam, size=size)
            cw, chh = font.measure("M"), font.metrics("linespace")
            rows = round(COLS * cw / chh)
            if COLS * cw <= sw - 40 and rows * chh <= sh - 120:
                break

        self.eye = Eye(COLS, cw, chh)
        W, H = self.eye.W, self.eye.H
        self.box = tk.Frame(root, width=W, height=H, bg="#000000", highlightthickness=0, bd=0)
        self.box.pack()
        self.box.pack_propagate(False)
        self.text = tk.Text(self.box, width=COLS, height=self.eye.rows, font=font, bg="#000000",
                            fg="#000000", bd=0, highlightthickness=0, padx=0, pady=0,
                            wrap="none", cursor="arrow", spacing1=0, spacing2=0, spacing3=0,
                            insertwidth=0, takefocus=0, state="disabled")
        self.text.place(x=0, y=0)
        for i, (r, g, b) in enumerate(PAL):
            self.text.tag_configure(TAGS[i], foreground="#%02x%02x%02x" % (r, g, b))
        self.status = tk.Label(root, text="", bg="#000000", fg="#5a1a0a", font=(fam, 9))
        self.status.pack(fill="x")

        self.t0 = time.perf_counter()
        self.last = self.t0
        self.dir = Director(0.0)
        self.fps = 0.0
        self.W, self.H = W, H

        root.bind("<space>", lambda e: self.dir.toggle(self.now()))
        root.bind("<Escape>", lambda e: root.destroy())
        root.bind("q", lambda e: root.destroy())
        root.bind("<Motion>", self.on_motion)
        x = (sw - W) // 2
        y = max(0, (sh - H - 60) // 2)
        root.geometry("+%d+%d" % (x, y))
        root.focus_force()
        self.tick()

    def now(self):
        return time.perf_counter() - self.t0

    def on_motion(self, e):
        x = e.x_root - self.box.winfo_rootx()
        y = e.y_root - self.box.winfo_rooty()
        if 0 <= x <= self.W and 0 <= y <= self.H:
            self.dir.mouse = (x / self.W * 2 - 1, y / self.H * 2 - 1)
            self.dir.mouse_t = self.now()

    def tick(self):
        s = time.perf_counter()
        t = s - self.t0
        dt = min(0.1, s - self.last)
        self.last = s
        d = self.dir
        d.update(t, dt)
        args = self.eye.render(t, d)
        tw = self.text
        tw.config(state="normal")
        tw.replace("1.0", "end-1c", args[0], *args[1:])
        tw.config(state="disabled")
        if d.shake > 0.02:
            m = int(1 + 3 * d.shake)
            tw.place(x=random.randint(-m, m), y=random.randint(-m, m))
        else:
            tw.place(x=0, y=0)
        el = time.perf_counter() - s
        self.fps = self.fps * 0.9 + (1.0 / max(dt, 1e-3)) * 0.1
        self.status.config(text="%s   ·   SPACE wake/sleep   ·   mouse = gaze   ·   ESC quit   ·   %d fps"
                           % (d.label(), self.fps))
        self.root.after(max(1, int(1000 / TARGET_FPS - el * 1000)), self.tick)


if __name__ == "__main__":
    App().root.mainloop()
