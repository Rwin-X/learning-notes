import html, re

def esc(s): return html.escape(s, quote=True)

def md(s):
    s = html.escape(s, quote=False)
    s = re.sub(r"`([^`]+)`", r'<span class="ltr">\1</span>', s)
    s = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", s)
    return s

def code(label, text):
    return ('<div class="code-block"><div class="cb-top"><span class="cb-label">%s</span>'
            '<button class="copy-btn" type="button">کپی</button></div><pre><code>%s</code></pre></div>'
            % (esc(label), html.escape(text.strip("\n"), quote=False)))

def out(text, label="خروجی"):
    return '<div class="out-block"><span class="out-label">%s</span>%s</div>' % (label, html.escape(text, quote=False))

def field(h, inner): return '<div class="field"><h5>%s</h5>%s</div>' % (h, inner)

def concept(c, section):
    p = []
    if c.get("what"): p.append(field("چیست؟", "<p>%s</p>" % md(c["what"])))
    if c.get("why"): p.append(field("چرا مهم است؟", "<p>%s</p>" % md(c["why"])))
    if c.get("mental"): p.append(field("مدل ذهنی", "<p>%s</p>" % md(c["mental"])))
    if c.get("how"): p.append(field("پایتون این را چطور ارزیابی می‌کند", "<p>%s</p>" % md(c["how"])))
    if c.get("code"):
        inner = "".join(code(l, t) for l, t in c["code"])
        if c.get("out"): inner += out(c["out"], c.get("outlabel", "خروجی"))
        p.append(field("نحو و مثال", inner))
    if c.get("steps"):
        p.append(field("گام‌به‌گام", "<ul>%s</ul>" % "".join("<li>%s</li>" % md(x) for x in c["steps"])))
    if c.get("mistake"): p.append('<div class="callout cm"><h6>اشتباه رایج</h6><p>%s</p></div>' % md(c["mistake"]))
    if c.get("fix"): p.append('<div class="callout cf"><h6>راه‌حل درست</h6><p>%s</p></div>' % md(c["fix"]))
    if c.get("fixcode"): p.append(code("درست", c["fixcode"]))
    for h, t in c.get("extra", []): p.append(field(h, "<p>%s</p>" % md(t)))
    if c.get("ex"):
        kind, prompt, sol = c["ex"][0], c["ex"][1], c["ex"][2]
        body = code("solution", sol) if kind == "code" else "<p>%s</p>" % md(sol)
        if kind == "code" and len(c["ex"]) > 3: body += out(c["ex"][3])
        pcode = (code("", c["ex"][4]) if len(c["ex"]) > 4 else "")
        p.append('<div class="exercise-box"><h6>%s</h6><p>%s</p>%s<button class="solution-toggle" type="button">نمایش راه‌حل</button><div class="solution-body">%s</div></div>'
                 % (c.get("exlabel", "تمرین"), md(prompt), pcode, body))
    p.append('<div class="complete-row"><label><input type="checkbox" class="complete-check" data-id="%s"><span>این مفهوم را فهمیدم</span></label></div>' % c["id"])
    return ('<div class="concept" id="%s" data-title="%s" data-section="%s" data-ctx="%s">'
            '<button class="concept-head" type="button"><div class="chead-l"><span class="concept-idx">%s</span><span class="concept-title">%s</span></div><span class="chev">◂</span></button>'
            '<div class="concept-body">%s</div></div>'
            % (c["id"], esc(c["title"]), esc(section), esc(c.get("ctx", "")), c["idx"], md(c["title"]), "".join(p)))

PILL = {"beg": "pill-beg", "int": "pill-int", "adv": "pill-adv"}

def level(L):
    sec = "سطح %02d — %s" % (L["n"], L["name"])
    chips = "".join('<a class="topic-chip" href="#%s">%s</a>' % (c["id"], md(c.get("chip", c["title"]))) for c in L["concepts"])
    skills = "".join('<span class="skill-chip">%s</span>' % esc(x) for x in L["skills"])
    h = ['<section id="level-%d"><div class="container">' % L["n"],
         '<div class="section-head"><div class="level-head"><span class="level-badge">سطح %02d / 09</span><span class="pill %s">%s</span><span class="pill">~%s</span></div><h2>%s</h2><p>هدف: <strong>%s</strong> %s</p></div>'
         % (L["n"], PILL[L["diff"]], L["diff_label"], L["time"], L["name"], L["goal"], md(L["desc"])),
         '<div class="level-meta-grid"><div class="meta-card"><h4>پیش‌نیاز</h4><p>%s</p></div><div class="meta-card"><h4>زمان تخمینی</h4><p>%s</p></div><div class="meta-card"><h4>چالش پایانی</h4><p>%s</p></div><div class="meta-card"><h4>مهارت‌های کسب‌شده</h4><div class="skills-row">%s</div></div></div>'
         % (md(L["prereq"]), L["time"], md(L["final_short"]), skills),
         '<div class="topic-strip">%s</div>' % chips]
    h += [concept(c, sec) for c in L["concepts"]]
    pr = L["project"]
    h.append('<div class="level-project"><h4>پروژه سطح %02d</h4><h3>%s</h3><p>%s</p></div>' % (L["n"], md(pr[0]), pr[1]))
    fc = L["final"]
    h.append('<div class="final-challenge"><h4>چالش پایانی سطح %02d</h4><p>%s</p>' % (L["n"], (fc[0] if "<a " in fc[0] else md(fc[0]))))
    if len(fc) > 1: h.append('<button class="solution-toggle" type="button">نمایش راه‌حل</button><div class="solution-body">%s</div>' % code(fc[1], fc[2]))
    h.append("</div></div></section>")
    return "".join(h)

DIFFP = {"beginner": ("مبتدی", "pill-beg"), "intermediate": ("متوسط", "pill-int"), "advanced": ("پیشرفته", "pill-adv"), "professional": ("حرفه‌ای", "pill-adv")}

def project(P):
    lab, cls = DIFFP[P["diff"]]
    p = []
    p.append(field("هدف و صورت مسئله", "<p>%s</p>" % md(P["purpose"])))
    p.append(field("اهداف یادگیری", "<ul>%s</ul>" % "".join("<li>%s</li>" % md(x) for x in P["goals"])))
    if P.get("reqs"): p.append(field("نیازمندی‌ها و ورودی/خروجی", "<ul>%s</ul>" % "".join("<li>%s</li>" % md(x) for x in P["reqs"])))
    if P.get("arch"): p.append(field("معماری", "<p>%s</p>" % md(P["arch"])))
    if P.get("tree"): p.append(code("ساختار پروژه", P["tree"]))
    for l, t in P.get("code", []): p.append(code(l, t))
    if P.get("why"): p.append(field("چرا این کد کار می‌کند", "<p>%s</p>" % md(P["why"])))
    if P.get("test"): p.append(field("تست و موارد خاص", "<p>%s</p>" % md(P["test"])))
    if P.get("fail"): p.append(field("خطاهای رایج", "<p>%s</p>" % md(P["fail"])))
    if P.get("sec"): p.append(field("نکات امنیتی", "<p>%s</p>" % md(P["sec"])))
    if P.get("ext"): p.append(field("بهبود و گسترش", "<p>%s</p>" % md(P["ext"])))
    if P.get("port"): p.append(field("ارزش نمونه‌کار", "<p>%s</p>" % md(P["port"])))
    pid = "project-%d" % P["n"]
    p.append('<div class="complete-row"><label><input type="checkbox" class="complete-check" data-id="%s"><span>این پروژه را کامل کردم</span></label></div>' % pid)
    return ('<div class="project-card" id="%s" data-diff="%s" data-title="%s" data-section="پروژه‌ها" data-ctx="%s">'
            '<button class="concept-head" type="button"><div class="chead-l"><span class="concept-idx">PROJECT %02d</span><span class="concept-title">%s</span><span class="pill %s">%s</span></div><span class="chev">◂</span></button>'
            '<div class="concept-body">%s</div></div>'
            % (pid, P["diff"], esc(P["title"]), esc(P["purpose"][:90]), P["n"], md(P["title"]), cls, lab, "".join(p)))

def stdlib(M):
    return ('<div class="stdlib-card" data-title="%s" data-section="کتابخانه استاندارد" data-ctx="%s"><h4>%s</h4><p><strong>کاربرد:</strong> %s</p><p><strong>توابع رایج:</strong> %s</p><p><strong>کِی استفاده کنیم:</strong> %s</p>%s<p><strong>اشتباه رایج:</strong> %s</p><p><strong>کاربرد واقعی:</strong> %s</p></div>'
            % (esc(M["name"]), esc(M["purpose"][:80]), esc(M["name"]), md(M["purpose"]), md(M["common"]), md(M["when"]), code("python", M["code"]), md(M["mistake"]), md(M["real"])))

def cheat(title, rows):
    return ('<div class="cheat-card" data-title="مرجع سریع: %s" data-section="مرجع سریع" data-ctx="%s"><h4>%s</h4><table>%s</table></div>'
            % (esc(title), esc(" ".join(r[0] for r in rows[:3])), esc(title),
               "".join("<tr><td>%s</td><td>%s</td></tr>" % (html.escape(a, quote=False), md(b)) for a, b in rows)))
