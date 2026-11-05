#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ASCII PORTRAIT - رندر عکس شما به صورت اسکی آرت زنده (PIL + tkinter)

عکس آپلودشده (اسکلت درخشان داخل هودی، پس‌زمینه تیره) را می‌خواند، آن را به
شبکه‌ای از کاراکترهای ASCII تبدیل می‌کند که روشنایی هر پیکسل را با چگالی
گلیف نشان می‌دهند -- دقیقاً همان حس و رنگ phosphor سبز/سفیدی که در دیسک
dedsec.py استفاده شده: پس‌زمینه مشکی، فونت مونو، و یک Canvas تک‌لایه که فقط
متن را به‌روزرسانی می‌کند (نه کل تصویر) تا سریع بماند.

اجرا:
    pip install pillow numpy
    python ascii_portrait.py [مسیر عکس]

کنترل‌ها
  + / -        افزایش / کاهش تعداد ستون‌ها (جزئیات بیشتر/کمتر)
  C            چرخش بین پالت‌های رنگ (سبز فسفری / سفید / قرمز هشدار)
  I            معکوس کردن روشن/تیره
  S            ذخیره فریم فعلی به صورت فایل متنی (.txt)
  R            بارگذاری مجدد عکس از مسیر اصلی
  ESC / Q      خروج
"""
import sys
import os
import numpy as np
from PIL import Image
import tkinter as tk
import tkinter.font as tkfont

# ----------------------------------------------------------------------------
# تنظیمات
# ----------------------------------------------------------------------------
DEFAULT_IMAGE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "source.jpg")
COLS_LEVELS = [80, 110, 140, 170, 200, 240]   # تعداد ستون‌های کاراکتری در هر سطح جزئیات
START_LEVEL = 3

# از تیره به روشن - چگالی بصری کاراکترها (شبیه گلیف‌های dedsec.py)
RAMP = " .'`^\",:;Il!i><~+_-?][}{1)(|\\/tfjrxnuvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"
NRAMP = len(RAMP)

PALETTES = {
    "phosphor": {  # سبز فسفری - مثل dedsec.py
        "bg": "#000000",
        "lo": (0, 40, 10),
        "hi": (140, 255, 170),
        "status_fg": "#1f6b2a",
    },
    "white": {     # مونوکروم سفید/خاکستری - نزدیک‌تر به عکس اصلی
        "bg": "#000000",
        "lo": (10, 10, 12),
        "hi": (245, 248, 252),
        "status_fg": "#888888",
    },
    "alert": {     # قرمز هشدار دیدسک
        "bg": "#000000",
        "lo": (40, 0, 0),
        "hi": (255, 70, 60),
        "status_fg": "#7a1f1f",
    },
}
PAL_ORDER = ["white", "phosphor", "alert"]


def lerp(a, b, f):
    return a + (b - a) * f


def ramp_char(v):
    """v در بازه 0..1؛ تیره‌ترین تا روشن‌ترین گلیف را برمی‌گرداند."""
    i = int(v * (NRAMP - 1) + 0.5)
    i = 0 if i < 0 else (NRAMP - 1 if i >= NRAMP else i)
    return RAMP[i]


def image_to_ascii(img, cols, aspect_correct=2.0):
    """تصویر PIL را به یک آرایه‌ی NumPy از روشنایی (0..1) با cols*rows تبدیل می‌کند."""
    w, h = img.size
    cell_w = w / cols
    rows = max(1, int(cols * (h / w) / aspect_correct))
    small = img.convert("L").resize((cols, rows), Image.LANCZOS)
    arr = np.asarray(small, dtype=np.float32) / 255.0
    return arr, rows


class App:
    def __init__(self, image_path):
        self.image_path = image_path
        self.src = Image.open(image_path).convert("RGB")

        self.root = root = tk.Tk()
        root.title("ASCII PORTRAIT")
        root.configure(bg="#000000")
        root.resizable(False, False)

        avail = set(tkfont.families())
        self.fam = next((f for f in ("Cascadia Mono", "Consolas", "Menlo",
                                      "DejaVu Sans Mono", "Liberation Mono",
                                      "Courier New", "Courier") if f in avail), "Courier")

        self.cv = tk.Canvas(root, bg="#000000", highlightthickness=0, bd=0)
        self.cv.pack()
        self.status = tk.Label(root, text="", bg="#000000", fg="#1f6b2a",
                                font=(self.fam, 9), anchor="w", justify="left")
        self.status.pack(fill="x")

        self.level = START_LEVEL
        self.pal_idx = 0
        self.invert = False

        self.build()

        root.bind("<plus>", lambda e: self.change_level(1))
        root.bind("<equal>", lambda e: self.change_level(1))
        root.bind("<minus>", lambda e: self.change_level(-1))
        root.bind("c", lambda e: self.cycle_palette())
        root.bind("C", lambda e: self.cycle_palette())
        root.bind("i", lambda e: self.toggle_invert())
        root.bind("I", lambda e: self.toggle_invert())
        root.bind("s", lambda e: self.save_txt())
        root.bind("S", lambda e: self.save_txt())
        root.bind("r", lambda e: self.reload())
        root.bind("R", lambda e: self.reload())
        root.bind("<Escape>", lambda e: root.destroy())
        root.bind("q", lambda e: root.destroy())
        root.focus_force()

    # ---- ساخت / بازسازی کامل صحنه ----
    def build(self):
        root = self.root
        cols = COLS_LEVELS[self.level]
        bright, rows = image_to_ascii(self.src, cols)
        if self.invert:
            bright = 1.0 - bright

        # فونت را طوری انتخاب کن که کل شبکه در صفحه‌نمایش جا شود
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        for px in range(16, 4, -1):
            font = tkfont.Font(family=self.fam, size=-px)
            cw, ch = font.measure("M"), font.metrics("linespace")
            if cols * cw <= sw - 60 and rows * ch <= sh - 130:
                break
        self.font = font
        self.cw, self.ch = cw, ch
        W, H = cols * cw, rows * ch

        self.cv.delete("all")
        self.cv.config(width=W, height=H)

        pal = PALETTES[PAL_ORDER[self.pal_idx]]
        self.cv.config(bg=pal["bg"])
        root.configure(bg=pal["bg"])
        self.status.configure(bg=pal["bg"], fg=pal["status_fg"])

        lo, hi = pal["lo"], pal["hi"]
        # هر ردیف را به صورت یک آیتم متنیِ تک‌خطی رسم کن (مثل رویکرد لایه‌ای dedsec.py)
        # ولی چون رنگ هر کاراکتر باید جدا باشد، هر کاراکتر را تکی رسم می‌کنیم
        # با batching بر اساس باکت‌های روشنایی تا سریع بماند.
        NB = 24  # تعداد سطح‌های رنگ (باکت‌های روشنایی)
        bucket = np.clip((bright * (NB - 1) + 0.5).astype(np.int32), 0, NB - 1)
        chararr = np.vectorize(ramp_char)(bright)

        self.items = []
        for b in range(NB):
            mask = bucket == b
            if not mask.any():
                continue
            f = b / (NB - 1)
            col = tuple(int(lerp(lo[k], hi[k], f)) for k in range(3))
            hexcol = "#%02x%02x%02x" % col
            ys, xs = np.nonzero(mask)
            # متن تک‌خط برای هر پیکسل این باکت را به صورت کاراکترهای جداگانه رسم می‌کنیم
            for y, x in zip(ys.tolist(), xs.tolist()):
                ch_ = chararr[y, x]
                it = self.cv.create_text(x * cw, y * ch, anchor="nw",
                                          font=font, text=ch_, fill=hexcol)
                self.items.append(it)

        root.geometry("")
        root.update_idletasks()
        xo = (sw - root.winfo_reqwidth()) // 2
        yo = max(0, (sh - root.winfo_reqheight()) // 2 - 20)
        root.geometry("+%d+%d" % (xo, yo))

        self.cols, self.rows = cols, rows
        self._update_status()

    def _update_status(self):
        self.status.config(
            text="%s  |  %dx%d  |  palette: %s%s  |  +/- detail  |  C palette  |  I invert  |  S save .txt  |  R reload  |  ESC quit"
            % (os.path.basename(self.image_path), self.cols, self.rows,
               PAL_ORDER[self.pal_idx], "  (inverted)" if self.invert else ""))

    def change_level(self, d):
        self.level = max(0, min(len(COLS_LEVELS) - 1, self.level + d))
        self.build()

    def cycle_palette(self):
        self.pal_idx = (self.pal_idx + 1) % len(PAL_ORDER)
        self.build()

    def toggle_invert(self):
        self.invert = not self.invert
        self.build()

    def reload(self):
        self.src = Image.open(self.image_path).convert("RGB")
        self.build()

    def save_txt(self):
        cols = COLS_LEVELS[self.level]
        bright, rows = image_to_ascii(self.src, cols)
        if self.invert:
            bright = 1.0 - bright
        lines = ["".join(ramp_char(bright[y, x]) for x in range(cols)) for y in range(rows)]
        out_path = os.path.splitext(self.image_path)[0] + "_ascii.txt"
        with open(out_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))
        self.status.config(text="saved -> %s" % out_path)


if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_IMAGE
    if not os.path.isfile(path):
        sys.exit("Image not found: %s" % path)
    App(path).root.mainloop()
