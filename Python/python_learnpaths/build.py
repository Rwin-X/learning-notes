import sys, html
sys.path.insert(0, ".")
import tpl
from tpl import esc, md
from d1 import L1, L2, L3
from d2 import L4, L5, L6
from d3 import L7, L8, L9
import d4

LEVELS = [L1, L2, L3, L4, L5, L6, L7, L8, L9]
css = open("style.css", encoding="utf-8").read()
js = open("app.js", encoding="utf-8").read()
nconcepts = sum(len(L["concepts"]) for L in LEVELS)

short = ["مبانی", "هسته", "توابع", "شی‌گرایی", "فایل/خطا", "پیشرفته", "اتوماسیون/API", "تست/کیفیت", "دنیای واقعی"]
nav = '<a class="nav-link" href="#roadmap">نقشه‌راه</a>' + "".join(
    '<a class="nav-link" href="#level-%d">%02d %s</a>' % (i + 1, i + 1, short[i]) for i in range(9)) + \
    '<a class="nav-link" href="#projects">پروژه‌ها</a><a class="nav-link" href="#capstone">پروژه‌ی پایانی</a><a class="nav-link" href="#stdlib">کتابخانه‌ی استاندارد</a><a class="nav-link" href="#cheatsheet">مرجع سریع</a><a class="nav-link" href="#resources">منابع</a><a class="nav-link" href="#checklist">چک‌لیست</a>'

def roadmap():
    items = []
    for L in LEVELS:
        items.append('<div class="rm-item"><div class="rm-top"><span class="rm-num">سطح %02d</span><span class="rm-title"><a href="#level-%d">%s</a></span><span class="pill %s">%s</span><span class="pill">~%s</span></div><p class="rm-goal">%s %s</p><div class="bar"><div class="bar-fill" data-level="%d"></div></div><div class="rm-pct" data-level-pct="%d">0%% تکمیل</div></div>'
                     % (L["n"], L["n"], L["name"], tpl.PILL[L["diff"]], L["diff_label"], L["time"], L["goal"], md(L["desc"]), L["n"], L["n"]))
    return "".join(items)

hero = '''<header class="hero" id="top"><div class="container hero-grid"><div>
<span class="eyebrow">یک دوره‌ی کامل و مستقل، در یک فایل</span>
<h1>پایتون<br><span class="accentword">از صفر تا حرفه‌ای</span></h1>
<p class="lead">از اولین خط کد تا اتوماسیون واقعی، کار با API و دیتابیس، تست و توسعه‌ی نرم‌افزار با ذهنیت تولید؛ همه در یک صفحه، بدون ثبت‌نام و بدون سرور.</p>
<div class="hero-actions"><a href="#level-1" class="btn btn-primary">شروع یادگیری ←</a><a href="#roadmap" class="btn btn-secondary">مشاهده‌ی نقشه‌راه</a></div>
<div class="hero-stats"><div class="hero-stat"><b>۸۵–۱۱۰h</b><span>زمان تخمینی مطالعه</span></div><div class="hero-stat"><b>9</b><span>سطح</span></div><div class="hero-stat"><b id="statConcepts">%d+</b><span>درس مفهومی</span></div><div class="hero-stat"><b>17</b><span>پروژه + پروژه‌ی پایانی</span></div><div class="hero-stat"><b style="direction:rtl">هیچ</b><span>پیش‌نیاز</span></div></div></div>
<div class="hero-panel"><div class="hero-panel-bar"><i></i><i></i><i></i><span class="fname">hello.py</span></div>
<pre><code><span class="c-com"># your first Python program</span>
name = <span class="c-str">"Python"</span>
<span class="c-fn">print</span>(<span class="c-kw">f</span><span class="c-str">"Learning {name}"</span>)

<span class="c-com"># run it:</span>
<span class="c-com">$ python hello.py</span>
<span class="c-out">Learning Python</span></code></pre>
<div class="hero-note">برای خواندن نیازی به نصب چیزی نیست. وقتی به سطح ۰۱ رسیدی پایتون را روی سیستم خودت نصب کن تا کدها را اجرا کنی.</div></div></div></header>''' % nconcepts

parts = []
parts.append('<!DOCTYPE html><html lang="fa" dir="rtl"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>پایتون — از صفر تا حرفه‌ای</title><meta name="description" content="دوره‌ی کامل و مستقل پایتون: از اولین print() تا API، دیتابیس، تست و مهندسی نرم‌افزار."><style>%s</style></head><body>' % css)
parts.append('<nav class="topnav" id="topnav"><div class="topnav-inner"><button class="nav-toggle" id="navToggle" aria-label="باز کردن منو" aria-expanded="false">☰</button><a href="#top" class="brand"><span class="brand-mark" aria-hidden="true"></span><span>پایتون</span></a><div class="nav-scroll" id="navScroll">%s</div><div class="nav-actions"><button class="icon-btn" id="searchOpenBtn" title="جستجو (کلید /)" aria-label="باز کردن جستجو">⌕</button><div class="progress-pill" title="پیشرفت کلی دوره"><span class="ring" id="navRing" style="--gp:0"></span><span id="navPct">0%%</span></div></div></div></nav>' % nav)
parts.append('<div class="search-overlay" id="searchOverlay" role="dialog" aria-modal="true" aria-label="جستجوی دوره"><div class="search-box"><div class="search-input-row"><span aria-hidden="true" style="color:var(--text-faint)">⌕</span><input type="text" id="searchInput" placeholder="جستجو در مفاهیم، پروژه‌ها، ماژول‌ها، مرجع سریع…" aria-label="جستجوی محتوای دوره"><span class="search-esc">ESC</span></div><div class="search-results" id="searchResults"><div class="search-empty">برای جستجو در تمام سطح‌ها، پروژه‌ها و مراجع این دوره تایپ کنید.</div></div></div></div>')
parts.append(hero)
parts.append('<section id="roadmap"><div class="container"><div class="section-head"><div class="section-kicker">نقشه‌ی دوره</div><h2>نقشه‌راه کامل</h2><p>نُه سطح، هرکدام روی سطح قبلی ساخته می‌شود. هر سطح دقیقاً می‌گوید باید چه چیزی را از قبل بدانی.</p></div>'
             '<div class="roadmap-meta"><div class="rm-box"><b>9</b><span>سطح</span></div><div class="rm-box"><b>۸۵–۱۱۰h</b><span>زمان کل</span></div><div class="rm-box"><b id="rmConcepts">%d+</b><span>مفهوم</span></div><div class="rm-box"><b>17</b><span>پروژه</span></div><div class="rm-box"><b style="direction:rtl">هیچ</b><span>پیش‌نیاز</span></div><div class="rm-box"><b id="rmProgress">0%%</b><span>پیشرفت تو</span></div></div>'
             '<div class="roadmap-list">%s</div></div></section>' % (nconcepts, roadmap()))
for L in LEVELS: parts.append(tpl.level(L))
# projects
filt = "".join('<button class="filter-btn%s" data-filter="%s" type="button">%s</button>' % (" active" if k == "all" else "", k, v) for k, v in [("all", "همه"), ("beginner", "مبتدی"), ("intermediate", "متوسط"), ("advanced", "پیشرفته"), ("professional", "حرفه‌ای")])
parts.append('<section id="projects"><div class="container"><div class="section-head"><div class="section-kicker">بساز، فقط نخوان</div><h2>۱۷ پروژه‌ی تدریجی</h2><p>هر پروژه به سطحی که آماده‌ات می‌کند ارجاع دارد. دشواری از یک اسکریپت پنج‌دقیقه‌ای تا یک اپلیکیشن چندفایلی تست‌شده و مستند بالا می‌رود.</p></div><div class="project-filter">%s</div>%s</div></section>' % (filt, "".join(tpl.project(P) for P in d4.PROJECTS)))
parts.append('<section id="capstone"><div class="container"><div class="section-head"><div class="section-kicker">پروژه‌ی پایانی</div><h2>PulseOps — مرکز شخصی اتوماسیون و گزارش</h2><p>یک اپلیکیشن یکپارچه و آماده‌ی نمونه‌کار که تقریباً همه‌ی دوره را ترکیب می‌کند: توابع، شی‌گرایی، فایل، خطا، ماژول، دیتابیس، API، تست، لاگ، تنظیمات و طراحی امنیت‌محور.</p></div>%s</div></section>' % "".join(tpl.concept(c, "پروژه‌ی پایانی") for c in d4.CAPSTONE))
parts.append('<section id="stdlib"><div class="container"><div class="section-head"><div class="section-kicker">مرجع</div><h2>راهنمای کتابخانه‌ی استاندارد</h2><p>ماژول‌هایی که مدام سراغشان می‌روی. برای هرکدام: کاربرد، توابع رایج، کِی استفاده کنیم، مثال کوچک و اشتباه رایج.</p></div><div class="stdlib-grid">%s</div></div></section>' % "".join(tpl.stdlib(M) for M in d4.STDLIB))
parts.append('<section id="cheatsheet"><div class="container"><div class="section-head"><div class="section-kicker">مرجع سریع</div><h2>برگه‌ی تقلب پایتون</h2><p>جستجوی سریع برای نحوی که قبلاً در دوره دیده‌ای؛ برای آموزش از صفر نیست.</p></div><div class="cheat-grid">%s</div></div></section>' % "".join(tpl.cheat(t, r) for t, r in d4.CHEAT))
res = "".join('<div class="resource-card"><h4>%s</h4><ul>%s</ul></div>' % (t, "".join('<li><a href="%s" target="_blank" rel="noopener">%s</a><span>%s</span></li>' % (u, n, d) for u, n, d in items)) for t, items in d4.RESOURCES)
parts.append('<section id="resources"><div class="container"><div class="section-head"><div class="section-kicker">ادامه‌ی مسیر</div><h2>منابع</h2><p>منابع رسمی و معتبر برای عمیق‌تر شدن در هر چیزی که این دوره معرفی کرد.</p></div><div class="resource-grid">%s</div></div></section>' % res)
chk = "".join('<label><input type="checkbox" data-check-id="rc%d"><span>%s</span></label>' % (i + 1, esc(t)) for i, t in enumerate(d4.CHECK))
parts.append('<section id="checklist"><div class="container"><div class="section-head"><div class="section-kicker">خودارزیابی</div><h2>چک‌لیست آمادگی حرفه‌ای پایتون</h2><p>هر مورد را وقتی واقعاً برایت درست شد تیک بزن؛ در همین مرورگر ذخیره می‌شود.</p></div><div class="checklist" id="readinessChecklist">%s</div></div></section>' % chk)
parts.append('<footer><div class="container"><p>پایتون — از صفر تا حرفه‌ای. دوره‌ی تک‌فایل و مستقل؛ بدون ثبت‌نام، بدون ردیابی، بدون سرور. پیشرفتت فقط در همین مرورگر می‌ماند.</p></div></footer><div class="toast" id="toast" role="status" aria-live="polite"></div><script>%s</script></body></html>' % js)

out = "".join(parts)
open("/mnt/user-data/outputs/python-zero-to-professional-fa.html", "w", encoding="utf-8").write(out)
print("size KB", len(out.encode()) // 1024, "concepts", nconcepts)
